import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/test_case.dart';
import '../models/test_step.dart';
import '../services/test_provider.dart';
import '../utils/theme.dart';
import '../utils/app_localizations.dart';
import '../widgets/test_step_item.dart';

class TestCaseFormScreen extends StatefulWidget {
  final bool isEditing;
  final TestCase? testCase;

  const TestCaseFormScreen({
    Key? key,
    required this.isEditing,
    this.testCase,
  }) : super(key: key);

  @override
  State<TestCaseFormScreen> createState() => _TestCaseFormScreenState();
}

class _TestCaseFormScreenState extends State<TestCaseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _moduleController = TextEditingController();
  final List<TestStep> _steps = [];
  bool _isLoading = false;
  // Variables para animaciones
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.testCase != null) {
      _titleController.text = widget.testCase!.title;
      _descriptionController.text = widget.testCase!.description;
      if (widget.testCase!.module != null) {
        _moduleController.text = widget.testCase!.module!;
      }
      _steps.addAll(widget.testCase!.steps);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _moduleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? AppLocalizations.of(context).editTestCase : AppLocalizations.of(context).createTestCase),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _save,
              tooltip: AppLocalizations.of(context).saveTestCase,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).titleLabel,
                hintText: AppLocalizations.of(context).titleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).descriptionLabel,
                hintText: AppLocalizations.of(context).descriptionHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _moduleController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context).moduleLabel,
                hintText: AppLocalizations.of(context).moduleHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context).testSteps,
                  style: AppTheme.subheadingStyle,
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddStepDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(AppLocalizations.of(context).addStepButton),
                ),
              ],
            ),
            if (_steps.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(
                  AppLocalizations.of(context).dragToReorder,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            _steps.isEmpty
                ? _buildEmptyStepsPlaceholder()
                : _buildStepsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStepsPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 24, bottom: 24),
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
            Icons.format_list_numbered,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noStepsAddedYet,
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).stepsDescription,
            textAlign: TextAlign.center,
            style: AppTheme.smallStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildStepsList() {
    return Column(
      children: [
        ReorderableListView.builder(
          shrinkWrap: true,
          buildDefaultDragHandles: false,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _steps.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final TestStep item = _steps.removeAt(oldIndex);
              _steps.insert(newIndex, item);
            });
          },
          itemBuilder: (context, index) {
            return Padding(
              key: ValueKey(_steps[index].id),
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  // Icono para arrastrar
                  ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                      ),
                      child: const Icon(
                        Icons.drag_handle,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  // Contenido del paso
                  Expanded(
                    child: TestStepItem(
                      step: _steps[index],
                      index: index,
                      mode: TestStepItemMode.edit,
                      onEditStep: (step) => _showEditStepDialog(context, step, index),
                      onDeleteStep: (_) => _deleteStep(index),
                      isDraggable: false,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAddStepDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final expectedResultController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).addTestStep),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).stepDescriptionLabel,
                  hintText: AppLocalizations.of(context).stepDescriptionHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expectedResultController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).expectedResultLabel,
                  hintText: AppLocalizations.of(context).expectedResultHint,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty &&
                  expectedResultController.text.isNotEmpty) {
                setState(() {
                  _steps.add(TestStep(
                    description: descriptionController.text,
                    expectedResult: expectedResultController.text,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context).add),
          ),
        ],
      ),
    );
  }

  void _showEditStepDialog(BuildContext context, TestStep step, int index) {
    final descriptionController = TextEditingController(text: step.description);
    final expectedResultController = TextEditingController(text: step.expectedResult);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).editTestStep),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Step Description',
                  hintText: 'What action should be performed',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: expectedResultController,
                decoration: const InputDecoration(
                  labelText: 'Expected Result',
                  hintText: 'What should happen after the action',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (descriptionController.text.isNotEmpty &&
                  expectedResultController.text.isNotEmpty) {
                setState(() {
                  _steps[index] = TestStep(
                    id: step.id,
                    description: descriptionController.text,
                    expectedResult: expectedResultController.text,
                  );
                });
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context).update),
          ),
        ],
      ),
    );
  }

  void _deleteStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }
  
  // Ya no necesitamos estos métodos porque usamos ReorderableListView

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _steps.isEmpty) {
      if (_steps.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).pleaseAddAtLeastOneStep),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<TestProvider>(context, listen: false);
      
      // Asegurarse de que el módulo sea null si está vacío
      String? moduleValue = _moduleController.text.trim().isEmpty ? null : _moduleController.text.trim();

      if (widget.isEditing && widget.testCase != null) {
        // Update existing test case
        final updatedTestCase = widget.testCase!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text,
          steps: _steps,
          module: moduleValue,
        );
        await provider.updateTestCase(updatedTestCase);
      } else {
        // Create new test case
        await provider.createTestCase(
          _titleController.text,
          _descriptionController.text,
          _steps,
          moduleValue,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving test case: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}