import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/test_case.dart';
import '../models/test_execution.dart';
import '../utils/file_utils.dart';
import '../utils/app_localizations.dart';
import 'language_provider.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  static ReportService get instance => _instance;
  
  // Para almacenar el contexto actual y poder acceder a los providers
  BuildContext? _currentContext;
  
  // Método para establecer el contexto actual
  void setContext(BuildContext context) {
    _currentContext = context;
  }
  
  // Obtener el idioma actual
  Locale? getCurrentLocale() {
    if (_currentContext != null) {
      try {
        return Provider.of<LanguageProvider>(_currentContext!, listen: false).locale;
      } catch (e) {
        print('Error al obtener el idioma: $e');
      }
    }
    return null;
  }

  ReportService._internal();

  // Generate and save a markdown report for a test execution
  Future<File> generateReport(TestExecution execution, TestCase testCase, {BuildContext? context}) async {
    // Usar el contexto proporcionado o el almacenado
    final ctx = context ?? _currentContext;
    final locale = getCurrentLocale();
    
    // Generar el reporte con el idioma adecuado
    final String reportContent = execution.generateMarkdownReport(
      testCase,
      context: ctx,
      locale: locale,
    );
    
    // Obtener el título localizado para el reporte
    String reportTitle = testCase.title;
    if (ctx != null) {
      final localizations = AppLocalizations.of(ctx);
      // Usar el título completo del caso de prueba
      reportTitle = '${localizations.testCaseDetails} ${testCase.title}';
    }
    
    return await _saveReportToFile(reportContent, execution.id, reportTitle);
  }

  // Generate a summary report for multiple test executions
  Future<File> generateSummaryReport(List<TestExecution> executions, Map<String, TestCase> testCases, {BuildContext? context}) async {
    // Usar el contexto proporcionado o el almacenado
    final ctx = context ?? _currentContext;
    final locale = getCurrentLocale();
    
    // Obtener las traducciones según el contexto o locale
    AppLocalizations? localizations;
    if (ctx != null) {
      localizations = AppLocalizations.of(ctx);
    } else if (locale != null) {
      localizations = AppLocalizations(locale);
    }
    
    // Usar traducciones si están disponibles, o texto en inglés como fallback
    final summaryReportTitle = localizations != null ? 'Informe Resumen de Ejecuciones de Prueba QA' : 'QA Test Execution Summary Report';
    final generatedOnLabel = localizations != null ? 'Generado el' : 'Generated on';
    final overviewLabel = localizations != null ? 'Resumen' : 'Overview';
    final totalTestsExecutedLabel = localizations != null ? 'Total de Pruebas Ejecutadas' : 'Total Tests Executed';
    final passedLabel = localizations != null ? 'Aprobadas' : 'Passed';
    final failedLabel = localizations != null ? 'Fallidas' : 'Failed';
    final pendingIncompleteLabel = localizations != null ? 'Pendientes/Incompletas' : 'Pending/Incomplete';
    final passRateLabel = localizations != null ? 'Tasa de Aprobación' : 'Pass Rate';
    final testResultsLabel = localizations != null ? 'Resultados de las Pruebas' : 'Test Results';
    final testCaseLabel = localizations != null ? 'Caso de Prueba' : 'Test Case';
    final startedLabel = localizations != null ? 'Iniciado' : 'Started';
    final statusLabel = localizations != null ? 'Estado' : 'Status';
    final durationLabel = localizations != null ? 'Duración' : 'Duration';
    final executedByLabel = localizations != null ? 'Ejecutado Por' : 'Executed By';
    final passStatusLabel = localizations != null ? '✅ APROBADO' : '✅ PASS';
    final failStatusLabel = localizations != null ? '❌ FALLIDO' : '❌ FAIL';
    final pendingStatusLabel = localizations != null ? '⏳ PENDIENTE' : '⏳ PENDING';
    final minLabel = localizations != null ? 'min' : 'min';
    final inProgressLabel = localizations != null ? 'En progreso' : 'In progress';
    final notSpecifiedLabel = localizations != null ? 'No especificado' : 'Not specified';
    final detailedTestReportsLabel = localizations != null ? 'Informes Detallados de Pruebas' : 'Detailed Test Reports';
    final environmentLabel = localizations != null ? 'Entorno' : 'Environment';
    final stepsSummaryLabel = localizations != null ? 'Resumen de Pasos' : 'Steps Summary';
    final stepLabel = localizations != null ? 'Paso' : 'Step';
    final notesLabel = localizations != null ? 'Notas' : 'Notes';
    final notExecutedLabel = localizations != null ? 'No ejecutado' : 'Not executed';
    
    final buffer = StringBuffer();
    
    buffer.writeln('# $summaryReportTitle');
    buffer.writeln('');
    buffer.writeln('*$generatedOnLabel ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}*');
    buffer.writeln('');
    
    buffer.writeln('## $overviewLabel');
    buffer.writeln('');
    buffer.writeln('- **$totalTestsExecutedLabel**: ${executions.length}');
    
    final passedExecutions = executions.where((e) => e.passedOverall == true).length;
    final failedExecutions = executions.where((e) => e.passedOverall == false).length;
    final pendingExecutions = executions.where((e) => e.passedOverall == null).length;
    
    buffer.writeln('- **$passedLabel**: $passedExecutions');
    buffer.writeln('- **$failedLabel**: $failedExecutions');
    buffer.writeln('- **$pendingIncompleteLabel**: $pendingExecutions');
    
    final passRate = executions.isEmpty ? 0.0 : passedExecutions / executions.length;
    buffer.writeln('- **$passRateLabel**: ${(passRate * 100).toStringAsFixed(2)}%');
    buffer.writeln('');
    
    buffer.writeln('## $testResultsLabel');
    buffer.writeln('');
    buffer.writeln('| $testCaseLabel | $startedLabel | $statusLabel | $durationLabel | $executedByLabel |');
    buffer.writeln('|-----------|---------|--------|----------|-------------|');
    
    for (var execution in executions) {
      final testCase = testCases[execution.testCaseId];
      if (testCase == null) continue;
      
      final status = execution.passedOverall == true 
          ? passStatusLabel 
          : execution.passedOverall == false 
              ? failStatusLabel 
              : pendingStatusLabel;
      
      final duration = execution.completedAt != null 
          ? '${execution.duration.inMinutes} $minLabel' 
          : inProgressLabel;
      
      final executor = execution.executorName?.isNotEmpty == true 
          ? execution.executorName 
          : 'N/A';
      
      buffer.writeln('| ${testCase.title} | ${DateFormat('yyyy-MM-dd HH:mm').format(execution.startedAt)} | $status | $duration | $executor |');
    }
    
    buffer.writeln('');
    buffer.writeln('## $detailedTestReportsLabel');
    buffer.writeln('');
    
    for (var execution in executions) {
      final testCase = testCases[execution.testCaseId];
      if (testCase == null) continue;
      
      buffer.writeln('### ${testCase.title}');
      buffer.writeln('');
      buffer.writeln('- **$statusLabel**: ${execution.passedOverall == true ? passStatusLabel : execution.passedOverall == false ? failStatusLabel : pendingStatusLabel}');
      buffer.writeln('- **$startedLabel**: ${DateFormat('yyyy-MM-dd HH:mm').format(execution.startedAt)}');
      buffer.writeln('- **$environmentLabel**: ${execution.environment ?? notSpecifiedLabel}');
      
      if (execution.stepExecutions.isNotEmpty) {
        buffer.writeln('');
        buffer.writeln('#### $stepsSummaryLabel');
        buffer.writeln('');
        buffer.writeln('| # | $stepLabel | $statusLabel | $notesLabel |');
        buffer.writeln('|---|------|--------|-------|');
        
        for (var i = 0; i < testCase.steps.length; i++) {
          final step = testCase.steps[i];
          final stepExecution = execution.stepExecutions.firstWhere(
            (se) => se.stepId == step.id,
            orElse: () => StepExecution(stepId: step.id, passed: false, notes: notExecutedLabel),
          );
          
          final status = stepExecution.passed ? passStatusLabel : failStatusLabel;
          final notes = stepExecution.notes ?? '';
          
          buffer.writeln('| ${i + 1} | ${step.description} | $status | $notes |');
        }
      }
      
      if (execution.additionalNotes?.isNotEmpty == true) {
        buffer.writeln('');
        buffer.writeln('#### $notesLabel');
        buffer.writeln('');
        buffer.writeln(execution.additionalNotes);
      }
      
      buffer.writeln('');
      buffer.writeln('---');
      buffer.writeln('');
    }
    
    final reportContent = buffer.toString();
    
    // Obtener el título localizado para el reporte
    String reportTitle = localizations != null ? 'Informe Resumen QA' : 'QA Summary Report';
    
    return await _saveReportToFile(reportContent, 'summary', reportTitle);
  }

  // Save the report content to a file
  Future<File> _saveReportToFile(String content, String identifier, String title) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    
    // Limpiar el título para usarlo como nombre de archivo
    // Reemplazar caracteres no válidos para nombres de archivo
    String safeTitle = title
        .replaceAll('/', '_')
        .replaceAll('\\', '_')
        .replaceAll(':', '_')
        .replaceAll('*', '_')
        .replaceAll('?', '_')
        .replaceAll('"', '_')
        .replaceAll('<', '_')
        .replaceAll('>', '_')
        .replaceAll('|', '_');
    
    // Limitar la longitud del título para evitar nombres de archivo demasiado largos
    if (safeTitle.length > 50) {
      safeTitle = safeTitle.substring(0, 50);
    }
    
    final fileName = '${safeTitle.replaceAll(' ', '_')}_${identifier}_$timestamp.md';
    final file = File('${directory.path}/reports/$fileName');
    
    // Ensure the reports directory exists
    await Directory('${directory.path}/reports').create(recursive: true);
    
    // Write the content to the file
    return await file.writeAsString(content);
  }

  // Share a report file
  Future<void> shareReport(File reportFile, {String subject = 'QA Test Report', BuildContext? context}) async {
    try {
      if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        // Para plataformas de escritorio, mostrar la ruta del archivo
        if (context != null) {
          await FileUtils.showFileInfoDialog(
            context, 
            reportFile, 
            title: 'Informe Guardado'
          );
        } else {
          // Si no tenemos contexto, intentar abrir el archivo directamente
          await FileUtils.openFile(reportFile);
        }
      } else {
        // En plataformas móviles, usamos share_plus normalmente
        await Share.shareXFiles(
          [XFile(reportFile.path)],
          subject: subject,
        );
      }
    } catch (e) {
      // Manejar el error sin lanzar una excepción para no interrumpir la aplicación
      print('Error al compartir archivo: $e');
    }
  }

  // Get all saved report files
  Future<List<File>> getSavedReports() async {
    final directory = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${directory.path}/reports');
    
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
      return [];
    }
    
    final reports = await reportsDir.list()
        .where((entity) => entity is File && entity.path.endsWith('.md'))
        .map((entity) => entity as File)
        .toList();
    
    // Sort by last modified time
    reports.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    
    return reports;
  }

  // Delete a report file
  Future<void> deleteReport(File reportFile) async {
    if (await reportFile.exists()) {
      await reportFile.delete();
    }
  }
}