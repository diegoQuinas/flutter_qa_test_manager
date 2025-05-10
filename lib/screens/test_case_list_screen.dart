import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_case.dart';
import '../services/test_provider.dart';
import '../utils/theme.dart';
import '../utils/app_localizations.dart';
import '../utils/animations.dart';
import '../widgets/test_case_card.dart';
import 'test_case_detail_screen.dart';
import 'test_case_form_screen.dart';
import 'test_execution_screen.dart';
import 'test_reports_screen.dart';
import 'settings_screen.dart';

class TestCaseListScreen extends StatefulWidget {
  const TestCaseListScreen({Key? key}) : super(key: key);

  @override
  State<TestCaseListScreen> createState() => _TestCaseListScreenState();
}

class _TestCaseListScreenState extends State<TestCaseListScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _selectedModule;
  List<String> _availableModules = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    // Usar post-frame callback para evitar errores de setState durante la construcción
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
    
    _animationController.forward();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<TestProvider>(context, listen: false);
    // Pasar el contexto al inicializar para que se use el idioma configurado
    await provider.init(context: context);
    
    // Extract all unique modules
    final modules = provider.testCases
        .where((tc) => tc.module != null && tc.module!.isNotEmpty)
        .map((tc) => tc.module!)
        .toSet()
        .toList();
    modules.sort();
    
    setState(() {
      _isLoading = false;
      _availableModules = modules;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).homeScreenTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showModuleFilterDialog,
            tooltip: AppLocalizations.of(context).filter,
          ),
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => _navigateToReportsScreen(context),
            tooltip: AppLocalizations.of(context).allReportsAction,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettingsScreen(context),
            tooltip: AppLocalizations.of(context).settings,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: PulseAnimation(
        duration: const Duration(milliseconds: 2000),
        child: FloatingActionButton.extended(
          onPressed: () => _navigateToAddScreen(context),
          icon: const Icon(Icons.add),
          label: Text(AppLocalizations.of(context).newTestButtonLabel),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: LoadingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 14,
          spacing: 8,
        ),
      );
    }

    return Consumer<TestProvider>(
      builder: (context, provider, child) {
        if (provider.error != null) {
          return AnimatedContent(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).errorLoadingTestCases,
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
                    child: Text(AppLocalizations.of(context).retry),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.testCases.isEmpty) {
          return AnimatedContent(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PulseAnimation(
                    child: Icon(
                      Icons.assignment_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context).noTestCasesYet,
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).tapToCreateFirstTest,
                    style: AppTheme.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _getFilteredTestCases(provider).length,
                  itemBuilder: (context, index) {
                    final testCase = _getFilteredTestCases(provider)[index];
                    return AnimatedListItem(
                      index: index,
                      child: TestCaseCard(
                        testCase: testCase,
                        onTap: () => _navigateToDetailScreen(context, testCase),
                        onEdit: () => _navigateToEditScreen(context, testCase),
                        onDelete: () => _confirmDelete(context, testCase),
                        onExecute: () => _navigateToExecutionScreen(context, testCase),
                        onViewReports: () => _navigateToTestReportsScreen(context, testCase),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteTransitions.fadeSlideTransition(
        page: const TestCaseFormScreen(
          isEditing: false,
        ),
        direction: SlideDirection.fromBottom,
      ),
    ).then((_) => _loadData());
  }

  void _navigateToEditScreen(BuildContext context, TestCase testCase) {
    Navigator.push(
      context,
      PageRouteTransitions.fadeSlideTransition(
        page: TestCaseFormScreen(
          isEditing: true,
          testCase: testCase,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToDetailScreen(BuildContext context, TestCase testCase) {
    final provider = Provider.of<TestProvider>(context, listen: false);
    provider.setActiveTestCase(testCase);
    Navigator.push(
      context,
      PageRouteTransitions.scaleTransition(
        page: TestCaseDetailScreen(testCase: testCase),
      ),
    ).then((_) => _loadData());
  }

  void _navigateToExecutionScreen(BuildContext context, TestCase testCase) {
    final provider = Provider.of<TestProvider>(context, listen: false);
    provider.setActiveTestCase(testCase);
    Navigator.push(
      context,
      PageRouteTransitions.fadeSlideTransition(
        page: TestExecutionScreen(testCase: testCase),
        direction: SlideDirection.fromRight,
      ),
    ).then((_) => _loadData());
  }

  void _navigateToTestReportsScreen(BuildContext context, TestCase testCase) {
    final provider = Provider.of<TestProvider>(context, listen: false);
    provider.setActiveTestCase(testCase);
    provider.loadExecutionsForTestCase(testCase.id);
    Navigator.push(
      context,
      PageRouteTransitions.fadeSlideTransition(
        page: TestReportsScreen(testCase: testCase),
        direction: SlideDirection.fromLeft,
      ),
    );
  }

  void _navigateToReportsScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteTransitions.fadeTransition(
        page: const TestReportsScreen(),
      ),
    );
  }
  
  void _navigateToSettingsScreen(BuildContext context) {
    Navigator.push(
      context,
      PageRouteTransitions.fadeSlideTransition(
        page: const SettingsScreen(),
        direction: SlideDirection.fromTop,
      ),
    );
  }
  
  List<TestCase> _getFilteredTestCases(TestProvider provider) {
    if (_selectedModule == null) {
      return provider.testCases;
    }
    
    return provider.testCases.where((testCase) => 
      testCase.module == _selectedModule
    ).toList();
  }
  
  void _showModuleFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).filterByModule),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context).allModules),
                leading: const Icon(Icons.view_list),
                selected: _selectedModule == null,
                onTap: () {
                  setState(() {
                    _selectedModule = null;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              ..._availableModules.map((module) => 
                ListTile(
                  title: Text(module),
                  leading: const Icon(Icons.category),
                  selected: _selectedModule == module,
                  onTap: () {
                    setState(() {
                      _selectedModule = module;
                    });
                    Navigator.pop(context);
                  },
                )
              ),
              if (_availableModules.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    AppLocalizations.of(context).noModule,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, TestCase testCase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).deleteTestCase),
        content: Text(
          AppLocalizations.of(context).deleteTestCaseConfirmation(testCase.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteTestCase(testCase);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context).delete),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTestCase(TestCase testCase) async {
    final provider = Provider.of<TestProvider>(context, listen: false);
    await provider.deleteTestCase(testCase.id);
    await _loadData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${testCase.title} ${AppLocalizations.of(context).testCaseDeletedMessage}"),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
      );
    }
  }
}