import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/test_case.dart';
import '../utils/theme.dart';
import '../utils/app_localizations.dart';
import '../utils/animations.dart';

class TestCaseCard extends StatefulWidget {
  final TestCase testCase;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onExecute;
  final VoidCallback? onViewReports;

  const TestCaseCard({
    Key? key,
    required this.testCase,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onExecute,
    this.onViewReports,
  }) : super(key: key);

  @override
  State<TestCaseCard> createState() => _TestCaseCardState();
}

class _TestCaseCardState extends State<TestCaseCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
          _controller.forward();
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
          _controller.reverse();
        });
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              elevation: _isHovered ? 4 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.testCase.title,
                                  style: AppTheme.subheadingStyle,
                                ),
                                if (widget.testCase.module != null && widget.testCase.module!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        widget.testCase.module!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.testCase.description,
                                  style: AppTheme.smallStyle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _buildStatusIndicator(context),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context).steps(widget.testCase.steps.length),
                            style: AppTheme.smallStyle,
                          ),
                          Text(
                            AppLocalizations.of(context).createdOn(_formatDate(widget.testCase.createdAt)),
                            style: AppTheme.smallStyle,
                          ),
                        ],
                      ),
                      if (widget.testCase.isExecuted) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context).lastExecutedOn(_formatDate(widget.testCase.lastExecutedAt!)),
                              style: AppTheme.smallStyle,
                            ),
                            Text(
                              _getStatusText(context),
                              style: AppTheme.smallStyle.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    if (!widget.testCase.isExecuted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          AppLocalizations.of(context).notExecuted,
          style: AppTheme.smallStyle.copyWith(
            color: Colors.grey[600],
          ),
        ),
      );
    }

    final backgroundColor = widget.testCase.passedOverall == true
        ? Colors.green.withOpacity(0.2)
        : widget.testCase.passedOverall == false
            ? Colors.red.withOpacity(0.2)
            : Colors.amber.withOpacity(0.2);

    final textColor = widget.testCase.passedOverall == true
        ? Colors.green
        : widget.testCase.passedOverall == false
            ? Colors.red
            : Colors.amber[800];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(context),
        style: AppTheme.smallStyle.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getStatusText(BuildContext context) {
    return widget.testCase.passedOverall == true
        ? AppLocalizations.of(context).passed
        : widget.testCase.passedOverall == false
            ? AppLocalizations.of(context).failed
            : AppLocalizations.of(context).incomplete;
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: widget.onEdit,
            tooltip: 'Edit Test Case',
            color: Theme.of(context).colorScheme.primary,
          ),
        if (widget.onExecute != null)
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded),
            onPressed: widget.onExecute,
            tooltip: 'Execute Test',
            color: Colors.green,
          ),
        if (widget.onViewReports != null && widget.testCase.isExecuted)
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: widget.onViewReports,
            tooltip: 'View Reports',
            color: Theme.of(context).colorScheme.secondary,
          ),
        if (widget.onDelete != null)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: widget.onDelete,
            tooltip: 'Delete Test Case',
            color: Colors.red,
          ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    if (widget.testCase.passedOverall == true) {
      return Colors.green;
    } else if (widget.testCase.passedOverall == false) {
      return Colors.red;
    } else {
      return Colors.amber[800]!;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, y').format(date);
  }
}