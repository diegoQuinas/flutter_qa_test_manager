import 'package:flutter/material.dart';
import '../models/test_step.dart';
import '../utils/theme.dart';
import '../utils/app_localizations.dart';

enum TestStepItemMode { view, edit, execute }

class TestStepItem extends StatelessWidget {
  final TestStep step;
  final int index;
  final TestStepItemMode mode;
  final Function(TestStep)? onEditStep;
  final Function(TestStep)? onDeleteStep;
  final Function(TestStep, bool, String)? onRecordResult;
  final bool isDraggable;
  
  const TestStepItem({
    Key? key,
    required this.step,
    required this.index,
    this.mode = TestStepItemMode.view,
    this.onEditStep,
    this.onDeleteStep,
    this.onRecordResult,
    this.isDraggable = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case TestStepItemMode.view:
        return _buildViewMode(context);
      case TestStepItemMode.edit:
        return _buildEditMode(context);
      case TestStepItemMode.execute:
        return _buildExecuteMode(context);
      default:
        return _buildViewMode(context);
    }
  }

  Widget _buildViewMode(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  radius: 14,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.description,
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expected Result:',
                        style: AppTheme.smallStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.expectedResult,
                        style: AppTheme.bodyStyle,
                      ),
                    ],
                  ),
                ),
                if (onEditStep != null || onDeleteStep != null)
                  _buildActionMenu(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditMode(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: isDraggable 
            ? const BorderRadius.only(
                topRight: Radius.circular(12.0),
                bottomRight: Radius.circular(12.0),
              )
            : BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildStepContent(context),
      ),
    );
  }
  
  Widget _buildStepContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              radius: 14,
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.description,
                    style: AppTheme.subheadingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).expectedResultLabel + ':',
                    style: AppTheme.smallStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.expectedResult,
                    style: AppTheme.bodyStyle,
                  ),
                ],
              ),
            ),
            _buildActionMenu(context),
          ],
        ),
      ],
    );
  }

  Widget _buildExecuteMode(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(
          color: _getExecutionStatusColor(context),
          width: step.result != null ? 2.0 : 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  radius: 14,
                  child: Text('${index + 1}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.description,
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Expected Result:',
                        style: AppTheme.smallStyle.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.expectedResult,
                        style: AppTheme.bodyStyle,
                      ),
                      if (step.notes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Notes: ${step.notes}',
                            style: AppTheme.smallStyle.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (onRecordResult != null)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showResultDialog(context, true),
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('PASS'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showResultDialog(context, false),
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('FAIL'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (step.result != null)
                  Icon(
                    step.result == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: step.result == true
                        ? Colors.green
                        : Colors.red,
                    size: 28,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'edit' && onEditStep != null) {
          onEditStep!(step);
        } else if (value == 'delete' && onDeleteStep != null) {
          onDeleteStep!(step);
        }
      },
      itemBuilder: (context) => [
        if (onEditStep != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
        if (onDeleteStep != null)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete),
                SizedBox(width: 8),
                Text('Delete'),
              ],
            ),
          ),
      ],
    );
  }

  Color _getExecutionStatusColor(BuildContext context) {
    if (step.result == null) {
      return Theme.of(context).dividerColor;
    }
    return step.result == true ? Colors.green : Colors.red;
  }

  void _showResultDialog(BuildContext context, bool passed) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(passed ? 'Test Step Passed' : 'Test Step Failed'),
        content: TextField(
          controller: notesController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Add any observations or details about this step result',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onRecordResult != null) {
                onRecordResult!(step, passed, notesController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: passed ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}