import 'package:uuid/uuid.dart';
import 'test_step.dart';

class TestCase {
  final String id;
  String title;
  String description;
  String? module;
  List<TestStep> steps;
  DateTime createdAt;
  DateTime? lastExecutedAt;
  bool? passedOverall;

  TestCase({
    String? id,
    required this.title,
    required this.description,
    this.module,
    List<TestStep>? steps,
    DateTime? createdAt,
    this.lastExecutedAt,
    this.passedOverall,
  })  : id = id ?? const Uuid().v4(),
        steps = steps ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    // Convert boolean to int for SQLite
    int? passedOverallValue;
    if (passedOverall != null) {
      passedOverallValue = passedOverall! ? 1 : 0;
    }
    
    return {
      'id': id,
      'title': title,
      'description': description,
      'module': module,
      'created_at': createdAt.toIso8601String(),
      'last_executed_at': lastExecutedAt?.toIso8601String(),
      'passed_overall': passedOverallValue,
    };
  }

  factory TestCase.fromMap(Map<String, dynamic> map) {
    // Handle the conversion from SQLite integer to boolean
    bool? passedOverallValue;
    if (map['passed_overall'] != null) {
      if (map['passed_overall'] is bool) {
        passedOverallValue = map['passed_overall'];
      } else if (map['passed_overall'] is int) {
        passedOverallValue = map['passed_overall'] == 1;
      }
    }
    
    return TestCase(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      module: map['module'],
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      lastExecutedAt: map['last_executed_at'] != null
          ? DateTime.parse(map['last_executed_at'])
          : null,
      passedOverall: passedOverallValue,
    );
  }

  TestCase copyWith({
    String? id,
    String? title,
    String? description,
    String? module,
    List<TestStep>? steps,
    DateTime? createdAt,
    DateTime? lastExecutedAt,
    bool? passedOverall,
  }) {
    return TestCase(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      module: module ?? this.module,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      lastExecutedAt: lastExecutedAt ?? this.lastExecutedAt,
      passedOverall: passedOverall ?? this.passedOverall,
    );
  }

  void addStep(TestStep step) {
    steps.add(step);
  }

  void removeStep(String stepId) {
    steps.removeWhere((step) => step.id == stepId);
  }
  
  void reorderSteps(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final TestStep item = steps.removeAt(oldIndex);
    steps.insert(newIndex, item);
  }

  void updateStep(TestStep updatedStep) {
    final index = steps.indexWhere((step) => step.id == updatedStep.id);
    if (index != -1) {
      steps[index] = updatedStep;
    }
  }

  void markStepResult(String stepId, bool result, {String? notes}) {
    final index = steps.indexWhere((step) => step.id == stepId);
    if (index != -1) {
      steps[index] = steps[index].copyWith(
        result: result,
        notes: notes ?? steps[index].notes,
      );
    }
  }

  bool get isExecuted => lastExecutedAt != null;

  int get totalSteps => steps.length;

  int get executedSteps =>
      steps.where((step) => step.result != null).length;

  int get passedSteps =>
      steps.where((step) => step.result == true).length;

  bool get isFullyExecuted => totalSteps > 0 && executedSteps == totalSteps;

  double get executionProgress {
    if (totalSteps == 0) return 0.0;
    return executedSteps / totalSteps;
  }

  double get passRate {
    if (executedSteps == 0) return 0.0;
    return passedSteps / executedSteps;
  }
}