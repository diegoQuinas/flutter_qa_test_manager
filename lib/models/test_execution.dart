import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'test_case.dart';
import '../utils/app_localizations.dart';

class StepExecution {
  final String id;
  final String stepId;
  final bool passed;
  final String? notes;
  final DateTime executedAt;

  StepExecution({
    String? id,
    required this.stepId,
    required this.passed,
    this.notes,
    DateTime? executedAt,
  })  : id = id ?? const Uuid().v4(),
        executedAt = executedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    // Convert boolean to int for SQLite
    final int passedValue = passed ? 1 : 0;
    
    return {
      'id': id,
      'step_id': stepId,
      'passed': passedValue,
      'notes': notes,
      'executed_at': executedAt.toIso8601String(),
    };
  }

  factory StepExecution.fromMap(Map<String, dynamic> map) {
    // Handle the conversion from SQLite integer to boolean
    bool passedValue;
    if (map['passed'] is bool) {
      passedValue = map['passed'];
    } else {
      passedValue = map['passed'] == 1;
    }
    
    return StepExecution(
      id: map['id'],
      stepId: map['step_id'],
      passed: passedValue,
      notes: map['notes'],
      executedAt: DateTime.parse(map['executed_at']),
    );
  }
}

class TestExecution {
  final String id;
  final String testCaseId;
  final DateTime startedAt;
  DateTime? completedAt;
  List<StepExecution> stepExecutions;
  bool? passedOverall;
  String? executorName;
  String? environment;
  String? additionalNotes;

  TestExecution({
    String? id,
    required this.testCaseId,
    DateTime? startedAt,
    this.completedAt,
    List<StepExecution>? stepExecutions,
    this.passedOverall,
    this.executorName,
    this.environment,
    this.additionalNotes,
  })  : id = id ?? const Uuid().v4(),
        startedAt = startedAt ?? DateTime.now(),
        stepExecutions = stepExecutions ?? [];

  Map<String, dynamic> toMap() {
    // Ensure we're converting boolean to int for SQLite
    int? passedOverallValue;
    if (passedOverall != null) {
      passedOverallValue = passedOverall! ? 1 : 0;
    }
    
    return {
      'id': id,
      'test_case_id': testCaseId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'passed_overall': passedOverallValue,
      'executor_name': executorName,
      'environment': environment,
      'additional_notes': additionalNotes,
    };
  }

  factory TestExecution.fromMap(Map<String, dynamic> map) {
    // Handle the conversion from SQLite integer to boolean
    bool? passedOverallValue;
    if (map['passed_overall'] != null) {
      if (map['passed_overall'] is bool) {
        passedOverallValue = map['passed_overall'];
      } else if (map['passed_overall'] is int) {
        passedOverallValue = map['passed_overall'] == 1;
      }
    }
    
    return TestExecution(
      id: map['id'],
      testCaseId: map['test_case_id'],
      startedAt: DateTime.parse(map['started_at']),
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'])
          : null,
      passedOverall: passedOverallValue,
      executorName: map['executor_name'],
      environment: map['environment'],
      additionalNotes: map['additional_notes'],
    );
  }

  TestExecution copyWith({
    String? id,
    String? testCaseId,
    DateTime? startedAt,
    DateTime? completedAt,
    List<StepExecution>? stepExecutions,
    bool? passedOverall,
    String? executorName,
    String? environment,
    String? additionalNotes,
  }) {
    return TestExecution(
      id: id ?? this.id,
      testCaseId: testCaseId ?? this.testCaseId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      stepExecutions: stepExecutions ?? this.stepExecutions,
      passedOverall: passedOverall ?? this.passedOverall,
      executorName: executorName ?? this.executorName,
      environment: environment ?? this.environment,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }

  void addStepExecution(StepExecution stepExecution) {
    stepExecutions.add(stepExecution);
  }

  bool get isCompleted => completedAt != null;

  void complete({bool? passed}) {
    completedAt = DateTime.now();
    if (passed != null) {
      passedOverall = passed;
    } else {
      // Automatically determine if all steps passed
      passedOverall = stepExecutions.every((step) => step.passed);
    }
  }

  Duration get duration {
    final end = completedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  double get passRate {
    if (stepExecutions.isEmpty) return 0.0;
    final passedCount = stepExecutions.where((step) => step.passed).length;
    return passedCount / stepExecutions.length;
  }

  // Helper method to generate markdown report for this execution
  String generateMarkdownReport(TestCase testCase, {BuildContext? context, Locale? locale}) {
    // Obtener las traducciones según el contexto o locale
    AppLocalizations? localizations;
    if (context != null) {
      localizations = AppLocalizations.of(context);
    } else if (locale != null) {
      // Si no tenemos contexto pero tenemos locale, creamos una instancia directamente
      localizations = AppLocalizations(locale);
    }
    
    final buffer = StringBuffer();
    
    // Usar traducciones si están disponibles, o texto en inglés como fallback
    final testExecutionReport = localizations != null ? 'Informe de Ejecución de Prueba' : 'Test Execution Report';
    final testCaseLabel = localizations != null ? 'Caso de Prueba' : 'Test Case';
    final executionIdLabel = localizations != null ? 'ID de Ejecución' : 'Execution ID';
    final startedAtLabel = localizations != null ? 'Iniciado En' : 'Started At';
    final completedAtLabel = localizations != null ? 'Completado En' : 'Completed At';
    final notCompletedLabel = localizations != null ? 'No completado' : 'Not completed';
    final durationLabel = localizations != null ? 'Duración' : 'Duration';
    final minutesLabel = localizations != null ? 'minutos' : 'minutes';
    final overallResultLabel = localizations != null ? 'Resultado General' : 'Overall Result';
    final passedLabel = localizations != null ? '✅ Aprobado' : '✅ Passed';
    final failedLabel = localizations != null ? '❌ Fallido' : '❌ Failed';
    final notDeterminedLabel = localizations != null ? 'No determinado' : 'Not determined';
    final executedByLabel = localizations != null ? 'Ejecutado Por' : 'Executed By';
    final environmentLabel = localizations != null ? 'Entorno' : 'Environment';
    final testDescriptionLabel = localizations != null ? 'Descripción de la Prueba' : 'Test Description';
    final testStepsLabel = localizations != null ? 'Pasos de la Prueba' : 'Test Steps';
    final stepLabel = localizations != null ? 'Paso' : 'Step';
    final descriptionLabel = localizations != null ? 'Descripción' : 'Description';
    final expectedResultLabel = localizations != null ? 'Resultado Esperado' : 'Expected Result';
    final statusLabel = localizations != null ? 'Estado' : 'Status';
    final notesLabel = localizations != null ? 'Notas' : 'Notes';
    final passLabel = localizations != null ? '✅ Aprobado' : '✅ Pass';
    final failLabel = localizations != null ? '❌ Fallido' : '❌ Fail';
    final notExecutedLabel = localizations != null ? 'No ejecutado' : 'Not executed';
    final additionalNotesLabel = localizations != null ? 'Notas Adicionales' : 'Additional Notes';
    final reportGeneratedLabel = localizations != null ? 'Informe generado el' : 'Report generated on';
    
    buffer.writeln('# $testExecutionReport');
    buffer.writeln('');
    buffer.writeln('## $testCaseLabel: ${testCase.title}');
    buffer.writeln('');
    buffer.writeln('- **$executionIdLabel**: $id');
    buffer.writeln('- **$startedAtLabel**: ${DateFormat('yyyy-MM-dd HH:mm').format(startedAt.toLocal())}');
    buffer.writeln('- **$completedAtLabel**: ${completedAt != null ? DateFormat('yyyy-MM-dd HH:mm').format(completedAt!.toLocal()) : notCompletedLabel}');
    buffer.writeln('- **$durationLabel**: ${duration.inMinutes} $minutesLabel');
    buffer.writeln('- **$overallResultLabel**: ${passedOverall == true ? passedLabel : passedOverall == false ? failedLabel : notDeterminedLabel}');
    
    if (executorName != null && executorName!.isNotEmpty) {
      buffer.writeln('- **$executedByLabel**: $executorName');
    }
    
    if (environment != null && environment!.isNotEmpty) {
      buffer.writeln('- **$environmentLabel**: $environment');
    }
    
    buffer.writeln('');
    buffer.writeln('## $testDescriptionLabel');
    buffer.writeln('');
    buffer.writeln(testCase.description);
    buffer.writeln('');
    
    buffer.writeln('## $testStepsLabel');
    buffer.writeln('');
    buffer.writeln('| # | $stepLabel $descriptionLabel | $expectedResultLabel | $statusLabel | $notesLabel |');
    buffer.writeln('|---|-----------------|-----------------|--------|-------|');
    
    for (var i = 0; i < testCase.steps.length; i++) {
      final step = testCase.steps[i];
      StepExecution stepExecution;
      try {
        stepExecution = stepExecutions.firstWhere(
          (execution) => execution.stepId == step.id,
        );
      } catch (e) {
        stepExecution = StepExecution(stepId: step.id, passed: false, notes: notExecutedLabel);
      }
      
      final status = stepExecution.passed ? passLabel : failLabel;
      final notes = stepExecution.notes ?? '';
      
      buffer.writeln('| ${i + 1} | ${step.description} | ${step.expectedResult} | $status | $notes |');
    }
    
    if (additionalNotes != null && additionalNotes!.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('## $additionalNotesLabel');
      buffer.writeln('');
      buffer.writeln(additionalNotes);
    }
    
    buffer.writeln('');
    buffer.writeln('*$reportGeneratedLabel ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now().toLocal())}*');
    
    return buffer.toString();
  }
}