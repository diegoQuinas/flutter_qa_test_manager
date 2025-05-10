import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/test_case.dart';
import '../services/test_provider.dart';
import '../utils/theme.dart';
import '../widgets/test_step_item.dart';
import 'test_execution_screen.dart';
import 'test_case_form_screen.dart';
import 'test_reports_screen.dart';

class TestCaseDetailScreen extends StatefulWidget {
  final TestCase testCase;

  const TestCaseDetailScreen({
    Key? key,
    required this.testCase,
  }) : super(key: key);

  @override
  State<TestCaseDetailScreen> createState() => _TestCaseDetailScreenState();
}

class _TestCaseDetailScreenState extends State<TestCaseDetailScreen> {
  bool _isLoading = false;
  TestCase? _testCase;

  @override
  void initState() {
    super.initState();
    _testCase = widget.testCase;
    
    // Usar post-frame callback para evitar errores de setState durante la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExecutions();
    });
  }

  Future<void> _loadExecutions() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      await provider.loadExecutionsForTestCase(_testCase!.id);
    } catch (e) {
      // Error handling will be done via the provider's error property
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Case Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEditScreen(context),
            tooltip: 'Edit Test Case',
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => _navigateToExecutionScreen(context),
            tooltip: 'Execute Test',
          ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => _navigateToReportsScreen(context),
            tooltip: 'View Reports',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadExecutions,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTestStepsSection(),
            const SizedBox(height: 24),
            _buildExecutionHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
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
                Expanded(
                  child: Text(
                    _testCase!.title,
                    style: AppTheme.headingStyle,
                  ),
                ),
                _buildStatusBadge(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _testCase!.description,
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Created on ${DateFormat('MMM d, y').format(_testCase!.createdAt)}',
                  style: AppTheme.smallStyle.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                if (_testCase!.isExecuted)
                  Text(
                    'Last executed on ${DateFormat('MMM d, y').format(_testCase!.lastExecutedAt!)}',
                    style: AppTheme.smallStyle.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (!_testCase!.isExecuted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Not Executed',
          style: AppTheme.smallStyle.copyWith(
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final backgroundColor = _testCase!.passedOverall == true
        ? Colors.green.withOpacity(0.2)
        : _testCase!.passedOverall == false
            ? Colors.red.withOpacity(0.2)
            : Colors.amber.withOpacity(0.2);

    final textColor = _testCase!.passedOverall == true
        ? Colors.green
        : _testCase!.passedOverall == false
            ? Colors.red
            : Colors.amber[800];

    final text = _testCase!.passedOverall == true
        ? 'PASSED'
        : _testCase!.passedOverall == false
            ? 'FAILED'
            : 'INCOMPLETE';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTheme.smallStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTestStepsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Test Steps',
              style: AppTheme.subheadingStyle,
            ),
            Text(
              '${_testCase!.steps.length} steps',
              style: AppTheme.smallStyle,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_testCase!.steps.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'No steps defined for this test case',
                style: AppTheme.bodyStyle,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _testCase!.steps.length,
            itemBuilder: (context, index) {
              return TestStepItem(
                step: _testCase!.steps[index],
                index: index,
                mode: TestStepItemMode.view,
              );
            },
          ),
      ],
    );
  }

  Widget _buildExecutionHistorySection() {
    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return Center(
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text('Error loading executions: ${provider.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loadExecutions,
                  child: const Text('RETRY'),
                ),
              ],
            ),
          );
        }

        if (provider.executions.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Execution History',
                style: AppTheme.subheadingStyle,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No executions yet',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Execute this test case to see the results here.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToExecutionScreen(context),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('EXECUTE TEST'),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Execution History',
                  style: AppTheme.subheadingStyle,
                ),
                TextButton.icon(
                  onPressed: () => _navigateToReportsScreen(context),
                  icon: const Icon(Icons.assessment_outlined),
                  label: const Text('VIEW ALL'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: provider.executions.length > 3 ? 3 : provider.executions.length,
              itemBuilder: (context, index) {
                final execution = provider.executions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: Icon(
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
                    ),
                    title: Text('Executed on ${DateFormat('MMM d, y HH:mm').format(execution.startedAt)}'),
                    subtitle: Text(
                      'Status: ${execution.passedOverall == true ? 'Passed' : execution.passedOverall == false ? 'Failed' : 'Incomplete'}'
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.description_outlined),
                      onPressed: () => _generateReport(execution.id),
                      tooltip: 'Generate Report',
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestCaseFormScreen(
          isEditing: true,
          testCase: _testCase,
        ),
      ),
    ).then((_) {
      // Refresh test case after editing
      setState(() {
        _testCase = Provider.of<TestProvider>(context, listen: false).activeTestCase;
      });
    });
  }

  void _navigateToExecutionScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestExecutionScreen(testCase: _testCase!),
      ),
    ).then((_) {
      _loadExecutions();
      setState(() {
        _testCase = Provider.of<TestProvider>(context, listen: false).activeTestCase;
      });
    });
  }

  void _navigateToReportsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestReportsScreen(testCase: _testCase),
      ),
    );
  }

  Future<void> _generateReport(String executionId) async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      // Pasar el contexto para que se use el idioma configurado
      final reportFile = await provider.generateTestReport(executionId, context: context);
      
      if (reportFile != null && mounted) {
        await provider.shareReport(reportFile, context: context);
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
}