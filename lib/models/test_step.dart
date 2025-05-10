import 'package:uuid/uuid.dart';

class TestStep {
  final String id;
  final String description;
  final String expectedResult;
  bool? result;
  String? notes;

  TestStep({
    String? id,
    required this.description,
    required this.expectedResult,
    this.result,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    // Convert boolean to int for SQLite
    int? resultValue;
    if (result != null) {
      resultValue = result! ? 1 : 0;
    }
    
    return {
      'id': id,
      'description': description,
      'expected_result': expectedResult,
      'result': resultValue,
      'notes': notes,
    };
  }

  factory TestStep.fromMap(Map<String, dynamic> map) {
    // Handle the conversion from SQLite integer to boolean
    bool? resultValue;
    if (map['result'] != null) {
      if (map['result'] is bool) {
        resultValue = map['result'];
      } else if (map['result'] is int) {
        resultValue = map['result'] == 1;
      }
    }
    
    return TestStep(
      id: map['id'],
      description: map['description'],
      expectedResult: map['expected_result'],
      result: resultValue,
      notes: map['notes'],
    );
  }

  TestStep copyWith({
    String? id,
    String? description,
    String? expectedResult,
    bool? result,
    String? notes,
  }) {
    return TestStep(
      id: id ?? this.id,
      description: description ?? this.description,
      expectedResult: expectedResult ?? this.expectedResult,
      result: result ?? this.result,
      notes: notes ?? this.notes,
    );
  }
}