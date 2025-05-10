import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/test_case.dart';
import '../models/test_step.dart';
import '../models/test_execution.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static DatabaseService get instance => _instance;

  DatabaseService._internal();

  static Database? _database;
  
  // Flag para controlar si estamos en modo de reinicio de base de datos
  bool _resetMode = false;

  Future<Database> get database async {
    if (_database != null && !_resetMode) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'qa_test_cases.db');
    
    // Si estamos en modo de reinicio, eliminar la base de datos existente
    if (_resetMode) {
      if (await databaseExists(path)) {
        await deleteDatabase(path);
      }
      _resetMode = false; // Restauramos el modo normal después de reiniciar
    }

    return await openDatabase(
      path,
      version: 2, // Incrementamos la versión para manejar la migración
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Test cases table
    await db.execute('''
      CREATE TABLE test_cases (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        module TEXT,
        created_at TEXT NOT NULL,
        last_executed_at TEXT,
        passed_overall INTEGER
      )
    ''');

    // Test steps table
    await db.execute('''
      CREATE TABLE test_steps (
        id TEXT PRIMARY KEY,
        test_case_id TEXT NOT NULL,
        description TEXT NOT NULL,
        expected_result TEXT NOT NULL,
        result INTEGER,
        notes TEXT,
        FOREIGN KEY (test_case_id) REFERENCES test_cases (id) ON DELETE CASCADE
      )
    ''');

    // Test executions table
    await db.execute('''
      CREATE TABLE test_executions (
        id TEXT PRIMARY KEY,
        test_case_id TEXT NOT NULL,
        started_at TEXT NOT NULL,
        completed_at TEXT,
        passed_overall INTEGER,
        executor_name TEXT,
        environment TEXT,
        additional_notes TEXT,
        FOREIGN KEY (test_case_id) REFERENCES test_cases (id) ON DELETE CASCADE
      )
    ''');

    // Step executions table
    await db.execute('''
      CREATE TABLE step_executions (
        id TEXT PRIMARY KEY,
        execution_id TEXT NOT NULL,
        step_id TEXT NOT NULL,
        passed INTEGER NOT NULL,
        notes TEXT,
        executed_at TEXT NOT NULL,
        FOREIGN KEY (execution_id) REFERENCES test_executions (id) ON DELETE CASCADE,
        FOREIGN KEY (step_id) REFERENCES test_steps (id) ON DELETE CASCADE
      )
    ''');
  }
  
  // Manejamos la migración de la base de datos
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Actualizar de versión 1 a 2 (agregar columna module)
    if (oldVersion == 1 && newVersion >= 2) {
      // Verificar si la columna module ya existe en la tabla test_cases
      var tableInfo = await db.rawQuery("PRAGMA table_info(test_cases)");
      bool hasModuleColumn = tableInfo.any((column) => column['name'] == 'module');
      
      if (!hasModuleColumn) {
        await db.execute('ALTER TABLE test_cases ADD COLUMN module TEXT;');
      }
    }
  }
  
  // Método para reiniciar la base de datos
  Future<void> resetDatabase() async {
    // Cerrar la base de datos si está abierta
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
    
    // Activar el modo de reinicio
    _resetMode = true;
    
    // Inicializar la base de datos nuevamente (esto eliminará la base de datos existente)
    await database;
  }

  // Test Case Methods
  Future<String> insertTestCase(TestCase testCase) async {
    final db = await database;
    
    // Insert the test case
    await db.insert(
      'test_cases',
      testCase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert all the steps
    for (var step in testCase.steps) {
      await db.insert(
        'test_steps',
        {
          ...step.toMap(),
          'test_case_id': testCase.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    return testCase.id;
  }

  Future<void> updateTestCase(TestCase testCase) async {
    final db = await database;
    
    await db.update(
      'test_cases',
      testCase.toMap(),
      where: 'id = ?',
      whereArgs: [testCase.id],
    );
  }

  Future<TestCase> getTestCase(String id) async {
    final db = await database;
    
    // Get the test case
    final List<Map<String, dynamic>> testCaseMaps = await db.query(
      'test_cases',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (testCaseMaps.isEmpty) {
      throw Exception('TestCase not found: $id');
    }
    
    // Get all the steps for this test case
    final List<Map<String, dynamic>> stepMaps = await db.query(
      'test_steps',
      where: 'test_case_id = ?',
      whereArgs: [id],
    );
    
    final TestCase testCase = TestCase.fromMap(testCaseMaps.first);
    testCase.steps = stepMaps.map((map) => TestStep.fromMap(map)).toList();
    
    return testCase;
  }

  Future<List<TestCase>> getAllTestCases() async {
    final db = await database;
    
    // Get all test cases
    final List<Map<String, dynamic>> testCaseMaps = await db.query('test_cases');
    
    // Convert the maps to TestCase objects
    List<TestCase> testCases = [];
    
    for (var testCaseMap in testCaseMaps) {
      final TestCase testCase = TestCase.fromMap(testCaseMap);
      
      // Get all steps for this test case
      final List<Map<String, dynamic>> stepMaps = await db.query(
        'test_steps',
        where: 'test_case_id = ?',
        whereArgs: [testCase.id],
      );
      
      testCase.steps = stepMaps.map((map) => TestStep.fromMap(map)).toList();
      testCases.add(testCase);
    }
    
    return testCases;
  }

  Future<void> deleteTestCase(String id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Delete steps first to maintain referential integrity
      await txn.delete(
        'test_steps',
        where: 'test_case_id = ?',
        whereArgs: [id],
      );
      
      // Then delete the test case
      await txn.delete(
        'test_cases',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  // Test Step Methods
  Future<void> insertTestStep(String testCaseId, TestStep step) async {
    final db = await database;
    
    await db.insert(
      'test_steps',
      {
        ...step.toMap(),
        'test_case_id': testCaseId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateTestStep(TestStep step, String testCaseId) async {
    final db = await database;
    
    await db.update(
      'test_steps',
      {
        ...step.toMap(),
        'test_case_id': testCaseId,
      },
      where: 'id = ?',
      whereArgs: [step.id],
    );
  }

  Future<void> deleteTestStep(String id) async {
    final db = await database;
    
    await db.delete(
      'test_steps',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Test Execution Methods
  Future<String> insertTestExecution(TestExecution execution) async {
    final db = await database;
    
    // Insert the execution
    await db.insert(
      'test_executions',
      execution.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    // Insert all step executions
    for (var stepExecution in execution.stepExecutions) {
      await db.insert(
        'step_executions',
        {
          ...stepExecution.toMap(),
          'execution_id': execution.id,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // Update the test case's last execution date
    await db.update(
      'test_cases',
      {
        'last_executed_at': execution.startedAt.toIso8601String(),
        'passed_overall': execution.passedOverall == null ? null : (execution.passedOverall! ? 1 : 0),
      },
      where: 'id = ?',
      whereArgs: [execution.testCaseId],
    );
    
    return execution.id;
  }

  Future<TestExecution> getTestExecution(String id) async {
    final db = await database;
    
    // Get the execution
    final List<Map<String, dynamic>> executionMaps = await db.query(
      'test_executions',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (executionMaps.isEmpty) {
      throw Exception('TestExecution not found: $id');
    }
    
    // Get all the step executions for this execution
    final List<Map<String, dynamic>> stepExecutionMaps = await db.query(
      'step_executions',
      where: 'execution_id = ?',
      whereArgs: [id],
    );
    
    final TestExecution execution = TestExecution.fromMap(executionMaps.first);
    execution.stepExecutions = stepExecutionMaps.map((map) => StepExecution.fromMap(map)).toList();
    
    return execution;
  }

  Future<List<TestExecution>> getTestExecutionsForTestCase(String testCaseId) async {
    final db = await database;
    
    // Get all executions for this test case
    final List<Map<String, dynamic>> executionMaps = await db.query(
      'test_executions',
      where: 'test_case_id = ?',
      whereArgs: [testCaseId],
      orderBy: 'started_at DESC',
    );
    
    // Convert the maps to TestExecution objects
    List<TestExecution> executions = [];
    
    for (var executionMap in executionMaps) {
      final TestExecution execution = TestExecution.fromMap(executionMap);
      
      // Get all step executions for this execution
      final List<Map<String, dynamic>> stepExecutionMaps = await db.query(
        'step_executions',
        where: 'execution_id = ?',
        whereArgs: [execution.id],
      );
      
      execution.stepExecutions = stepExecutionMaps.map((map) => StepExecution.fromMap(map)).toList();
      executions.add(execution);
    }
    
    return executions;
  }

  Future<void> updateTestExecution(TestExecution execution) async {
    final db = await database;
    
    await db.update(
      'test_executions',
      execution.toMap(),
      where: 'id = ?',
      whereArgs: [execution.id],
    );
    
    // Update the test case's last execution info if needed
    if (execution.completedAt != null) {
      await db.update(
        'test_cases',
        {
          'last_executed_at': execution.completedAt!.toIso8601String(),
          'passed_overall': execution.passedOverall == null ? null : (execution.passedOverall! ? 1 : 0),
        },
        where: 'id = ?',
        whereArgs: [execution.testCaseId],
      );
    }
  }

  Future<void> insertStepExecution(String executionId, StepExecution stepExecution) async {
    final db = await database;
    
    await db.insert(
      'step_executions',
      {
        ...stepExecution.toMap(),
        'execution_id': executionId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteTestExecution(String id) async {
    final db = await database;
    
    await db.transaction((txn) async {
      // Delete step executions first to maintain referential integrity
      await txn.delete(
        'step_executions',
        where: 'execution_id = ?',
        whereArgs: [id],
      );
      
      // Then delete the execution
      await txn.delete(
        'test_executions',
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }
}