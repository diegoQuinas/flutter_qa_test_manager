import 'dart:io';
import 'package:flutter/material.dart';
import '../models/test_case.dart';
import '../models/test_step.dart';
import '../models/test_execution.dart';
import 'database_service.dart';
import 'report_service.dart';

class TestProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final ReportService _reportService = ReportService.instance;
  
  List<TestCase> _testCases = [];
  List<TestExecution> _executions = [];
  TestCase? _activeTestCase;
  TestExecution? _activeExecution;
  bool _loading = false;
  String? _error;

  // Getters
  List<TestCase> get testCases => _testCases;
  List<TestExecution> get executions => _executions;
  TestCase? get activeTestCase => _activeTestCase;
  TestExecution? get activeExecution => _activeExecution;
  bool get loading => _loading;
  String? get error => _error;

  // Initialize provider
  Future<void> init({BuildContext? context}) async {
    _setLoading(true);
    try {
      // Si tenemos un contexto, establecerlo en el servicio de reportes
      if (context != null) {
        _reportService.setContext(context);
      }
      
      await _loadTestCases();
      _error = null;
    } catch (e) {
      _error = 'Failed to initialize: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Test Case Methods
  Future<void> _loadTestCases() async {
    _testCases = await _dbService.getAllTestCases();
    notifyListeners();
  }

  Future<void> createTestCase(String title, String description, List<TestStep> steps, String? module) async {
    _setLoading(true);
    try {
      final testCase = TestCase(
        title: title,
        description: description,
        steps: steps,
        module: module,
      );
      
      await _dbService.insertTestCase(testCase);
      await _loadTestCases();
      _error = null;
    } catch (e) {
      _error = 'Failed to create test case: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateTestCase(TestCase testCase) async {
    _setLoading(true);
    try {
      await _dbService.updateTestCase(testCase);
      
      // Also update the steps
      for (var step in testCase.steps) {
        await _dbService.updateTestStep(step, testCase.id);
      }
      
      await _loadTestCases();
      _error = null;
    } catch (e) {
      _error = 'Failed to update test case: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteTestCase(String id) async {
    _setLoading(true);
    try {
      await _dbService.deleteTestCase(id);
      await _loadTestCases();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete test case: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  void setActiveTestCase(TestCase? testCase) {
    _activeTestCase = testCase;
    notifyListeners();
  }

  // Test Step Methods
  Future<void> addStep(String testCaseId, TestStep step) async {
    _setLoading(true);
    try {
      await _dbService.insertTestStep(testCaseId, step);
      
      // Refresh the test cases
      await _loadTestCases();
      
      // Update active test case if needed
      if (_activeTestCase?.id == testCaseId) {
        _activeTestCase = _testCases.firstWhere((tc) => tc.id == testCaseId);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to add step: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateStep(TestStep step, String testCaseId) async {
    _setLoading(true);
    try {
      await _dbService.updateTestStep(step, testCaseId);
      
      // Refresh the test cases
      await _loadTestCases();
      
      // Update active test case if needed
      if (_activeTestCase?.id == testCaseId) {
        _activeTestCase = _testCases.firstWhere((tc) => tc.id == testCaseId);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to update step: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteStep(String stepId, String testCaseId) async {
    _setLoading(true);
    try {
      await _dbService.deleteTestStep(stepId);
      
      // Refresh the test cases
      await _loadTestCases();
      
      // Update active test case if needed
      if (_activeTestCase?.id == testCaseId) {
        _activeTestCase = _testCases.firstWhere((tc) => tc.id == testCaseId);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to delete step: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Test Execution Methods
  Future<void> loadExecutionsForTestCase(String testCaseId) async {
    _setLoading(true);
    try {
      _executions = await _dbService.getTestExecutionsForTestCase(testCaseId);
      _error = null;
    } catch (e) {
      _error = 'Failed to load executions: $e';
      _executions = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> startExecution(String testCaseId, {String? executorName, String? environment}) async {
    _setLoading(true);
    try {
      final execution = TestExecution(
        testCaseId: testCaseId,
        executorName: executorName,
        environment: environment,
      );
      
      final executionId = await _dbService.insertTestExecution(execution);
      _activeExecution = await _dbService.getTestExecution(executionId);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to start execution: $e';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> recordStepResult(String stepId, bool passed, {String? notes}) async {
    if (_activeExecution == null) return;
    
    _setLoading(true);
    try {
      final stepExecution = StepExecution(
        stepId: stepId,
        passed: passed,
        notes: notes,
      );
      
      await _dbService.insertStepExecution(_activeExecution!.id, stepExecution);
      
      // Add to the active execution
      _activeExecution!.addStepExecution(stepExecution);
      
      _error = null;
    } catch (e) {
      _error = 'Failed to record step result: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> completeExecution({bool? passed, String? additionalNotes}) async {
    if (_activeExecution == null) return;
    
    _setLoading(true);
    try {
      _activeExecution!.complete(passed: passed);
      _activeExecution!.additionalNotes = additionalNotes;
      
      await _dbService.updateTestExecution(_activeExecution!);
      
      // Refresh the test cases and executions
      await _loadTestCases();
      if (_activeTestCase != null) {
        await loadExecutionsForTestCase(_activeTestCase!.id);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to complete execution: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteExecution(String id) async {
    _setLoading(true);
    try {
      await _dbService.deleteTestExecution(id);
      
      // Refresh executions if active test case exists
      if (_activeTestCase != null) {
        await loadExecutionsForTestCase(_activeTestCase!.id);
      }
      
      _error = null;
    } catch (e) {
      _error = 'Failed to delete execution: $e';
    } finally {
      _setLoading(false);
    }
  }

  void setActiveExecution(TestExecution? execution) {
    _activeExecution = execution;
    notifyListeners();
  }

  // Report Methods
  Future<File?> generateTestReport(String executionId, {BuildContext? context}) async {
    _setLoading(true);
    try {
      final execution = await _dbService.getTestExecution(executionId);
      final testCase = await _dbService.getTestCase(execution.testCaseId);
      
      // Si tenemos un contexto, establecerlo en el servicio de reportes
      if (context != null) {
        _reportService.setContext(context);
      }
      
      final reportFile = await _reportService.generateReport(execution, testCase, context: context);
      _error = null;
      return reportFile;
    } catch (e) {
      _error = 'Failed to generate report: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<File?> generateSummaryReport({BuildContext? context}) async {
    _setLoading(true);
    try {
      // Get all test cases
      final testCases = await _dbService.getAllTestCases();
      
      // Create a map of test case IDs to test cases
      final testCaseMap = {for (var tc in testCases) tc.id: tc};
      
      // Get all executions (this is a simplified approach - in a real app,
      // you might want to filter by date range or only include recent executions)
      final allExecutions = <TestExecution>[];
      for (var testCase in testCases) {
        final executions = await _dbService.getTestExecutionsForTestCase(testCase.id);
        allExecutions.addAll(executions);
      }
      
      // Sort by most recent first
      allExecutions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
      
      // Si tenemos un contexto, establecerlo en el servicio de reportes
      if (context != null) {
        _reportService.setContext(context);
      }
      
      // Generate the summary report
      final reportFile = await _reportService.generateSummaryReport(
        allExecutions.take(50).toList(), // Limit to last 50 executions
        testCaseMap,
        context: context,
      );
      
      _error = null;
      return reportFile;
    } catch (e) {
      _error = 'Failed to generate summary report: $e';
      rethrow; // Rethrow to allow handling in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<List<File>> getSavedReports() async {
    try {
      return await _reportService.getSavedReports();
    } catch (e) {
      _error = 'Failed to get saved reports: $e';
      return [];
    }
  }

  Future<void> shareReport(File reportFile, {BuildContext? context}) async {
    try {
      await _reportService.shareReport(reportFile, context: context);
      _error = null;
    } catch (e) {
      _error = 'Failed to share report: $e';
      rethrow; // Rethrow to allow handling in UI
    }
  }

  Future<void> deleteReport(File reportFile) async {
    try {
      await _reportService.deleteReport(reportFile);
      _error = null;
    } catch (e) {
      _error = 'Failed to delete report: $e';
      rethrow; // Rethrow to allow handling in UI
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _loading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}