import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/test_case.dart';
import '../models/test_execution.dart';
import '../models/test_step.dart';
import '../services/test_provider.dart';
import '../utils/theme.dart';
import '../widgets/test_step_item.dart';
import '../main.dart';

class TestExecutionScreen extends StatefulWidget {
  final TestCase testCase;

  const TestExecutionScreen({
    Key? key,
    required this.testCase,
  }) : super(key: key);

  @override
  State<TestExecutionScreen> createState() => _TestExecutionScreenState();
}

class _TestExecutionScreenState extends State<TestExecutionScreen> {
  bool _isLoading = false;
  bool _isExecutionStarted = false;
  TestCase? _testCase;
  TestExecution? _execution;
  final _executorNameController = TextEditingController();
  final _environmentController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _testCase = widget.testCase;
  }

  @override
  void dispose() {
    _executorNameController.dispose();
    _environmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Execute Test Case'),
          actions: [
            if (_isExecutionStarted)
              IconButton(
                icon: const Icon(Icons.check_circle),
                onPressed: _completeExecution,
                tooltip: 'Complete Execution',
              ),
          ],
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_isExecutionStarted) {
      return _buildStartExecutionScreen();
    } else {
      return _buildExecutionScreen();
    }
  }

  Widget _buildStartExecutionScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _testCase!.title,
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _testCase!.description,
                    style: AppTheme.bodyStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Steps: ${_testCase!.steps.length}',
                    style: AppTheme.smallStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Execution Information',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _executorNameController,
            decoration: const InputDecoration(
              labelText: 'Your Name (Optional)',
              hintText: 'Who is executing this test',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _environmentController,
            decoration: const InputDecoration(
              labelText: 'Environment (Optional)',
              hintText: 'e.g., Production, Staging, Dev',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.web),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton.icon(
              onPressed: _startExecution,
              icon: const Icon(Icons.play_arrow),
              label: const Text('START EXECUTION'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionScreen() {
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        final execution = provider.activeExecution;
        if (execution == null) {
          return const Center(
            child: Text('Error: No active execution found'),
          );
        }

        // Find which steps have been executed
        final executedStepIds = execution.stepExecutions.map((e) => e.stepId).toSet();

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _testCase!.title,
                          style: AppTheme.subheadingStyle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Started: ${DateFormat('MMM d, y HH:mm').format(execution.startedAt)}',
                          style: AppTheme.smallStyle,
                        ),
                      ],
                    ),
                  ),
                  _buildProgressIndicator(executedStepIds.length, _testCase!.steps.length),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _testCase!.steps.length,
                itemBuilder: (context, index) {
                  final step = _testCase!.steps[index];
                  final isExecuted = executedStepIds.contains(step.id);
                  
                  // Find the step execution for this step if it exists
                  StepExecution? stepExecution;
                  for (var se in execution.stepExecutions) {
                    if (se.stepId == step.id) {
                      stepExecution = se;
                      break;
                    }
                  }
                  
                  // Update the step with results from execution
                  final updatedStep = isExecuted
                      ? step.copyWith(
                          result: stepExecution?.passed,
                          notes: stepExecution?.notes,
                        )
                      : step;
                  
                  return TestStepItem(
                    step: updatedStep,
                    index: index,
                    mode: TestStepItemMode.execute,
                    onRecordResult: (step, passed, notes) => 
                        _recordStepResult(step.id, passed, notes),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;
    final percentComplete = (progress * 100).toInt();
    
    return Column(
      children: [
        Text(
          '$percentComplete% Complete',
          style: AppTheme.smallStyle.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 100,
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.withOpacity(0.3),
            color: _getProgressColor(progress),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }

  Future<void> _startExecution() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      await provider.startExecution(
        _testCase!.id,
        executorName: _executorNameController.text.isNotEmpty
            ? _executorNameController.text
            : null,
        environment: _environmentController.text.isNotEmpty
            ? _environmentController.text
            : null,
      );
      
      setState(() {
        _isExecutionStarted = true;
        _execution = provider.activeExecution;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting execution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _recordStepResult(String stepId, bool passed, String notes) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      await provider.recordStepResult(
        stepId,
        passed,
        notes: notes.isNotEmpty ? notes : null,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error recording step result: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _completeExecution() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Test Execution'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add any additional notes about this test execution:'),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any observations or feedback about this test run',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _finalizeExecution();
            },
            child: const Text('COMPLETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _finalizeExecution() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      
      // Check if all steps are executed
      final execution = provider.activeExecution;
      final isFullyExecuted = execution != null && 
          execution.stepExecutions.length == _testCase!.steps.length;
      
      // Calculate overall pass/fail status
      final allPassed = execution != null &&
          execution.stepExecutions.every((step) => step.passed);
      
      // Only auto-determine pass/fail if all steps are executed
      final passedOverall = isFullyExecuted ? allPassed : null;
      
      await provider.completeExecution(
        passed: passedOverall,
        additionalNotes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test execution completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing execution: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_isExecutionStarted) return true;
    
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text(
          'This test execution is still in progress. If you leave now, you can continue it later, but make sure to complete it eventually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('LEAVE'),
          ),
        ],
      ),
    );
    
    return shouldPop ?? false;
  }
}