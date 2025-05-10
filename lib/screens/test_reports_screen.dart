import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/test_case.dart';
import '../models/test_execution.dart';
import '../services/test_provider.dart';
import '../utils/theme.dart';

class TestReportsScreen extends StatefulWidget {
  final TestCase? testCase;

  const TestReportsScreen({
    Key? key,
    this.testCase,
  }) : super(key: key);

  @override
  State<TestReportsScreen> createState() => _TestReportsScreenState();
}

class _TestReportsScreenState extends State<TestReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  File? _currentReportFile;
  String? _currentReportContent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Usar post-frame callback para evitar errores de setState durante la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      if (widget.testCase != null) {
        await provider.loadExecutionsForTestCase(widget.testCase!.id);
      }
    } catch (e) {
      // Error will be handled via provider's error property
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.testCase != null
            ? '${widget.testCase!.title} Reports'
            : 'Test Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(Icons.list),
              text: 'Executions',
            ),
            Tab(
              icon: Icon(Icons.description_outlined),
              text: 'Saved Reports',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExecutionsTab(),
          _buildSavedReportsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0 && widget.testCase != null
          ? FloatingActionButton.extended(
              onPressed: _generateSummaryReport,
              icon: const Icon(Icons.assessment),
              label: const Text('GENERATE SUMMARY'),
            )
          : null,
    );
  }

  Widget _buildExecutionsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading executions',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('RETRY'),
                ),
              ],
            ),
          );
        }

        if (provider.executions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Executions Found',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.testCase != null
                      ? 'Execute this test case to see reports'
                      : 'Execute test cases to generate reports',
                  style: AppTheme.bodyStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: provider.executions.length,
            itemBuilder: (context, index) {
              final execution = provider.executions[index];
              return _buildExecutionCard(execution);
            },
          ),
        );
      },
    );
  }

  Widget _buildExecutionCard(TestExecution execution) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  execution.passedOverall == true
                      ? Icons.check_circle
                      : execution.passedOverall == false
                          ? Icons.cancel
                          : Icons.pending,
                  color: execution.passedOverall == true
                      ? Colors.green
                      : execution.passedOverall == false
                          ? Colors.red
                          : Colors.amber,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Execution ${DateFormat('MMM d, y HH:mm').format(execution.startedAt)}',
                    style: AppTheme.subheadingStyle,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: execution.passedOverall == true
                        ? Colors.green.withOpacity(0.2)
                        : execution.passedOverall == false
                            ? Colors.red.withOpacity(0.2)
                            : Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    execution.passedOverall == true
                        ? 'PASSED'
                        : execution.passedOverall == false
                            ? 'FAILED'
                            : 'INCOMPLETE',
                    style: AppTheme.smallStyle.copyWith(
                      color: execution.passedOverall == true
                          ? Colors.green
                          : execution.passedOverall == false
                              ? Colors.red
                              : Colors.amber[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (execution.executorName != null &&
                execution.executorName!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Executed by: ${execution.executorName}',
                  style: AppTheme.smallStyle,
                ),
              ),
            if (execution.environment != null && execution.environment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  'Environment: ${execution.environment}',
                  style: AppTheme.smallStyle,
                ),
              ),
            Text(
              'Steps: ${execution.stepExecutions.length}',
              style: AppTheme.smallStyle,
            ),
            if (execution.isCompleted)
              Text(
                'Duration: ${execution.duration.inMinutes} minutes',
                style: AppTheme.smallStyle,
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _viewExecutionDetails(execution),
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('VIEW'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _generateReport(execution.id),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('REPORT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedReportsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<List<File>>(
      future: Provider.of<TestProvider>(context, listen: false).getSavedReports(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading saved reports',
                  style: AppTheme.subheadingStyle,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final reports = snapshot.data ?? [];

        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Saved Reports',
                  style: AppTheme.headingStyle,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Generate reports from test executions to see them here',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  Widget _buildReportCard(File report) {
    final fileName = report.path.split('/').last;
  
  // Extraer la fecha del nombre del archivo
  String dateStr = '';
  final parts = fileName.split('_');
  if (parts.length >= 2) {
    // Buscar la parte que parece una fecha en formato yyyyMMdd_HHmmss
    for (int i = 0; i < parts.length - 1; i++) {
      if (parts[i].length == 8 && parts[i+1].length == 6 && 
          RegExp(r'^\d{8}$').hasMatch(parts[i]) && 
          RegExp(r'^\d{6}$').hasMatch(parts[i+1])) {
        dateStr = '${parts[i]}_${parts[i+1]}';
        break;
      }
    }
  }
  
  DateTime? date;
  try {
    // Try to parse date from filename format yyyyMMdd_HHmmss
    if (dateStr.isNotEmpty) {
      date = DateFormat('yyyyMMdd_HHmmss').parse(dateStr);
    } else {
      throw Exception('Date format not found');
    }
  } catch (e) {
    // If can't parse, use file modified date
    date = report.lastModifiedSync();
  }

  // Extraer un nombre descriptivo del archivo
  String reportTitle = '';
  
  // Intentar extraer el nombre significativo del reporte
  if (fileName.contains('Detalle') || fileName.contains('Detail')) {
    // Es un reporte de caso de prueba individual
    final titleParts = fileName.split('_');
    // Buscar la parte después de "Detalle" o "Detail"
    int startIndex = -1;
    for (int i = 0; i < titleParts.length; i++) {
      if (titleParts[i].contains('Detalle') || titleParts[i].contains('Detail')) {
        startIndex = i + 1;
        break;
      }
    }
    
    if (startIndex >= 0 && startIndex < titleParts.length) {
      // Tomar partes hasta encontrar la fecha o el ID
      List<String> relevantParts = [];
      for (int i = startIndex; i < titleParts.length; i++) {
        // Detener si encontramos una parte que parece una fecha o un UUID
        if (RegExp(r'^\d{8}$').hasMatch(titleParts[i]) || 
            RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$').hasMatch(titleParts[i])) {
          break;
        }
        relevantParts.add(titleParts[i]);
      }
      
      if (relevantParts.isNotEmpty) {
        reportTitle = relevantParts.join(' ');
      } else {
        // Si no pudimos extraer un nombre, usar un título genérico
        reportTitle = 'Reporte de Caso de Prueba';
      }
    } else {
      reportTitle = 'Reporte de Caso de Prueba';
    }
  } else if (fileName.contains('Resumen') || fileName.contains('Summary')) {
    // Es un reporte de resumen
    reportTitle = fileName.contains('Resumen') ? 'Informe Resumen QA' : 'QA Summary Report';
  } else {
    // Caso genérico, usar el nombre del archivo sin la extensión y sin la fecha
    reportTitle = fileName.replaceAll('.md', '');
    // Quitar la parte de la fecha y el ID si están presentes
    if (dateStr.isNotEmpty) {
      reportTitle = reportTitle.replaceAll(dateStr, '');
    }
    // Limpiar guiones bajos y espacios extras
    reportTitle = reportTitle.replaceAll('_', ' ').trim();
    // Si está vacío, usar un nombre genérico
    if (reportTitle.isEmpty) {
      reportTitle = 'Reporte QA';
    }
  }

  return Card(
    margin: const EdgeInsets.only(bottom: 8.0),
    child: ListTile(
      leading: const Icon(Icons.description_outlined),
      title: Text(
        reportTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('Generado: ${DateFormat('MMM d, y HH:mm').format(date)}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility),
            onPressed: () => _viewSavedReport(report),
            tooltip: 'Ver Reporte',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(report),
            tooltip: 'Compartir',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDeleteReport(report),
            tooltip: 'Eliminar',
          ),
        ],
      ),
    ),
  );
}

  void _viewExecutionDetails(TestExecution execution) {
    // Get TestCase from provider
    final provider = Provider.of<TestProvider>(context, listen: false);
    final testCase = widget.testCase ?? 
        provider.testCases.firstWhere(
          (tc) => tc.id == execution.testCaseId,
          orElse: () => TestCase(
            title: 'Unknown Test',
            description: 'Test details not available',
          ),
        );
    
    final reportContent = execution.generateMarkdownReport(testCase);
    
    setState(() {
      _currentReportContent = reportContent;
      _currentReportFile = null;
    });
    
    _showReportDialog();
  }

  Future<void> _generateReport(String executionId) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      // Pasar el contexto para que se use el idioma configurado
      final reportFile = await provider.generateTestReport(executionId, context: context);
      
      if (reportFile != null) {
        final content = await reportFile.readAsString();
        setState(() {
          _currentReportFile = reportFile;
          _currentReportContent = content;
        });
        
        _showReportDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _generateSummaryReport() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      // Pasar el contexto para que se use el idioma configurado
      final reportFile = await provider.generateSummaryReport(context: context);
      
      if (reportFile != null) {
        final content = await reportFile.readAsString();
        setState(() {
          _currentReportFile = reportFile;
          _currentReportContent = content;
        });
        
        _showReportDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating summary report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _viewSavedReport(File reportFile) async {
    setState(() => _isLoading = true);
    
    try {
      final content = await reportFile.readAsString();
      setState(() {
        _currentReportFile = reportFile;
        _currentReportContent = content;
      });
      
      _showReportDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _shareReport(File reportFile) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      await provider.shareReport(reportFile, context: context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmDeleteReport(File reportFile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text(
          'Are you sure you want to delete this report? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteReport(reportFile);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteReport(File reportFile) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      await provider.deleteReport(reportFile);
      
      if (mounted) {
        // Refresh view
        setState(() {});
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted successfully'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showReportDialog() {
    if (_currentReportContent == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: Markdown(
            data: _currentReportContent!,
            shrinkWrap: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          if (_currentReportFile != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _shareReport(_currentReportFile!);
              },
              icon: const Icon(Icons.share),
              label: const Text('SHARE'),
            ),
        ],
      ),
    );
  }
}