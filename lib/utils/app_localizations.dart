import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'QA Test Manager',
      'homeScreenTitle': 'QA Test Cases',
      'allReportsAction': 'All Reports',
      'newTestButtonLabel': 'NEW TEST',
      'errorLoadingTestCases': 'Error loading test cases',
      'retry': 'RETRY',
      'noTestCasesYet': 'No test cases yet',
      'tapToCreateFirstTest': 'Tap the + button to create your first test case',
      'deleteTestCase': 'Delete Test Case',
      'cancel': 'CANCEL',
      'delete': 'DELETE',
      'testCaseDeletedMessage': 'Test case deleted',
      'settings': 'Settings',
      'language': 'Language',
      'english': 'English',
      'spanish': 'Spanish',
      'createTestCase': 'Create Test Case',
      'editTestCase': 'Edit Test Case',
      'saveTestCase': 'Save Test Case',
      'titleLabel': 'Title',
      'titleHint': 'Enter a descriptive title for the test case',
      'descriptionLabel': 'Description',
      'descriptionHint': 'Describe the purpose of this test case',
      'testSteps': 'Test Steps',
      'addStepButton': 'ADD STEP',
      'noStepsAddedYet': 'No steps added yet',
      'stepsDescription': 'Add steps to define what actions should be performed during this test.',
      'addTestStep': 'Add Test Step',
      'editTestStep': 'Edit Test Step',
      'stepDescriptionLabel': 'Step Description',
      'stepDescriptionHint': 'What action should be performed',
      'expectedResultLabel': 'Expected Result',
      'expectedResultHint': 'What should happen after the action',
      'add': 'ADD',
      'update': 'UPDATE',
      'pleaseAddAtLeastOneStep': 'Please add at least one test step',
      'testCaseDetails': 'Test Case Details',
      'executeTest': 'Execute Test',
      'viewReports': 'View Reports',
      'notExecuted': 'Not Executed',
      'passed': 'PASSED',
      'failed': 'FAILED',
      'incomplete': 'INCOMPLETE',
      'steps': 'Steps: {count}',
      'createdOn': 'Created on {date}',
      'lastExecutedOn': 'Last executed on {date}',
      'noStepsDefinedForThisTestCase': 'No steps defined for this test case',
      'executionHistory': 'Execution History',
      'noExecutionsYet': 'No executions yet',
      'executeToSeeResults': 'Execute this test case to see the results here.',
      'viewAll': 'VIEW ALL',
      'moduleLabel': 'Module',
      'moduleHint': 'Enter a module name (e.g. Login, Dashboard)',
      'editModule': 'Edit Module',
      'removeModule': 'Remove Module',
      'filter': 'Filter',
      'filterByModule': 'Filter by Module',
      'allModules': 'All Modules',
      'noModule': 'No Module',
      'dragToReorder': 'Drag to reorder steps',
      'errorSaving': 'Error saving: {error}',
    },
    'es': {
      'appTitle': 'Administrador de Pruebas QA',
      'homeScreenTitle': 'Casos de Prueba QA',
      'allReportsAction': 'Todos los Informes',
      'newTestButtonLabel': 'NUEVA PRUEBA',
      'errorLoadingTestCases': 'Error al cargar casos de prueba',
      'retry': 'REINTENTAR',
      'noTestCasesYet': 'Aún no hay casos de prueba',
      'tapToCreateFirstTest': 'Toca el botón + para crear tu primer caso de prueba',
      'deleteTestCase': 'Eliminar Caso de Prueba',
      'cancel': 'CANCELAR',
      'delete': 'ELIMINAR',
      'testCaseDeletedMessage': 'Caso de prueba eliminado',
      'settings': 'Configuración',
      'language': 'Idioma',
      'english': 'Inglés',
      'spanish': 'Español',
      'createTestCase': 'Crear Caso de Prueba',
      'editTestCase': 'Editar Caso de Prueba',
      'saveTestCase': 'Guardar Caso de Prueba',
      'titleLabel': 'Título',
      'titleHint': 'Ingresa un título descriptivo para el caso de prueba',
      'descriptionLabel': 'Descripción',
      'descriptionHint': 'Describe el propósito de este caso de prueba',
      'testSteps': 'Pasos de Prueba',
      'addStepButton': 'AGREGAR PASO',
      'noStepsAddedYet': 'Aún no se han agregado pasos',
      'stepsDescription': 'Agrega pasos para definir qué acciones se deben realizar durante esta prueba.',
      'addTestStep': 'Agregar Paso de Prueba',
      'editTestStep': 'Editar Paso de Prueba',
      'stepDescriptionLabel': 'Descripción del Paso',
      'stepDescriptionHint': 'Qué acción debe realizarse',
      'expectedResultLabel': 'Resultado Esperado',
      'expectedResultHint': 'Qué debe suceder después de la acción',
      'add': 'AGREGAR',
      'update': 'ACTUALIZAR',
      'pleaseAddAtLeastOneStep': 'Por favor, agrega al menos un paso de prueba',
      'testCaseDetails': 'Detalles del Caso de Prueba',
      'executeTest': 'Ejecutar Prueba',
      'viewReports': 'Ver Informes',
      'notExecuted': 'No Ejecutado',
      'passed': 'APROBADO',
      'failed': 'FALLIDO',
      'incomplete': 'INCOMPLETO',
      'steps': 'Pasos: {count}',
      'createdOn': 'Creado el {date}',
      'lastExecutedOn': 'Última ejecución el {date}',
      'noStepsDefinedForThisTestCase': 'No hay pasos definidos para este caso de prueba',
      'executionHistory': 'Historial de Ejecución',
      'noExecutionsYet': 'Aún no hay ejecuciones',
      'executeToSeeResults': 'Ejecuta este caso de prueba para ver los resultados aquí.',
      'viewAll': 'VER TODO',
      'moduleLabel': 'Módulo',
      'moduleHint': 'Ingresa un nombre de módulo (ej. Login, Dashboard)',
      'editModule': 'Editar Módulo',
      'removeModule': 'Eliminar Módulo',
      'filter': 'Filtrar',
      'filterByModule': 'Filtrar por Módulo',
      'allModules': 'Todos los Módulos',
      'noModule': 'Sin Módulo',
      'dragToReorder': 'Arrastra para reordenar los pasos',
      'errorSaving': 'Error al guardar: {error}',
    }
  };

  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'QA Test Manager';
  String get homeScreenTitle => _localizedValues[locale.languageCode]?['homeScreenTitle'] ?? 'QA Test Cases';
  String get allReportsAction => _localizedValues[locale.languageCode]?['allReportsAction'] ?? 'All Reports';
  String get newTestButtonLabel => _localizedValues[locale.languageCode]?['newTestButtonLabel'] ?? 'NEW TEST';
  String get errorLoadingTestCases => _localizedValues[locale.languageCode]?['errorLoadingTestCases'] ?? 'Error loading test cases';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'RETRY';
  String get noTestCasesYet => _localizedValues[locale.languageCode]?['noTestCasesYet'] ?? 'No test cases yet';
  String get tapToCreateFirstTest => _localizedValues[locale.languageCode]?['tapToCreateFirstTest'] ?? 'Tap the + button to create your first test case';
  String get deleteTestCase => _localizedValues[locale.languageCode]?['deleteTestCase'] ?? 'Delete Test Case';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'CANCEL';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'DELETE';
  String get testCaseDeletedMessage => _localizedValues[locale.languageCode]?['testCaseDeletedMessage'] ?? 'Test case deleted';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get spanish => _localizedValues[locale.languageCode]?['spanish'] ?? 'Spanish';
  String get createTestCase => _localizedValues[locale.languageCode]?['createTestCase'] ?? 'Create Test Case';
  String get editTestCase => _localizedValues[locale.languageCode]?['editTestCase'] ?? 'Edit Test Case';
  String get saveTestCase => _localizedValues[locale.languageCode]?['saveTestCase'] ?? 'Save Test Case';
  String get titleLabel => _localizedValues[locale.languageCode]?['titleLabel'] ?? 'Title';
  String get titleHint => _localizedValues[locale.languageCode]?['titleHint'] ?? 'Enter a descriptive title for the test case';
  String get descriptionLabel => _localizedValues[locale.languageCode]?['descriptionLabel'] ?? 'Description';
  String get descriptionHint => _localizedValues[locale.languageCode]?['descriptionHint'] ?? 'Describe the purpose of this test case';
  String get testSteps => _localizedValues[locale.languageCode]?['testSteps'] ?? 'Test Steps';
  String get addStepButton => _localizedValues[locale.languageCode]?['addStepButton'] ?? 'ADD STEP';
  String get noStepsAddedYet => _localizedValues[locale.languageCode]?['noStepsAddedYet'] ?? 'No steps added yet';
  String get stepsDescription => _localizedValues[locale.languageCode]?['stepsDescription'] ?? 'Add steps to define what actions should be performed during this test.';
  String get addTestStep => _localizedValues[locale.languageCode]?['addTestStep'] ?? 'Add Test Step';
  String get editTestStep => _localizedValues[locale.languageCode]?['editTestStep'] ?? 'Edit Test Step';
  String get stepDescriptionLabel => _localizedValues[locale.languageCode]?['stepDescriptionLabel'] ?? 'Step Description';
  String get stepDescriptionHint => _localizedValues[locale.languageCode]?['stepDescriptionHint'] ?? 'What action should be performed';
  String get expectedResultLabel => _localizedValues[locale.languageCode]?['expectedResultLabel'] ?? 'Expected Result';
  String get expectedResultHint => _localizedValues[locale.languageCode]?['expectedResultHint'] ?? 'What should happen after the action';
  String get add => _localizedValues[locale.languageCode]?['add'] ?? 'ADD';
  String get update => _localizedValues[locale.languageCode]?['update'] ?? 'UPDATE';
  String get pleaseAddAtLeastOneStep => _localizedValues[locale.languageCode]?['pleaseAddAtLeastOneStep'] ?? 'Please add at least one test step';
  String get testCaseDetails => _localizedValues[locale.languageCode]?['testCaseDetails'] ?? 'Test Case Details';
  String get executeTest => _localizedValues[locale.languageCode]?['executeTest'] ?? 'Execute Test';
  String get viewReports => _localizedValues[locale.languageCode]?['viewReports'] ?? 'View Reports';
  String get notExecuted => _localizedValues[locale.languageCode]?['notExecuted'] ?? 'Not Executed';
  String get passed => _localizedValues[locale.languageCode]?['passed'] ?? 'PASSED';
  String get failed => _localizedValues[locale.languageCode]?['failed'] ?? 'FAILED';
  String get incomplete => _localizedValues[locale.languageCode]?['incomplete'] ?? 'INCOMPLETE';
  String get noStepsDefinedForThisTestCase => _localizedValues[locale.languageCode]?['noStepsDefinedForThisTestCase'] ?? 'No steps defined for this test case';
  String get executionHistory => _localizedValues[locale.languageCode]?['executionHistory'] ?? 'Execution History';
  String get noExecutionsYet => _localizedValues[locale.languageCode]?['noExecutionsYet'] ?? 'No executions yet';
  String get executeToSeeResults => _localizedValues[locale.languageCode]?['executeToSeeResults'] ?? 'Execute this test case to see the results here.';
  String get viewAll => _localizedValues[locale.languageCode]?['viewAll'] ?? 'VIEW ALL';
  String get moduleLabel => _localizedValues[locale.languageCode]?['moduleLabel'] ?? 'Module';
  String get moduleHint => _localizedValues[locale.languageCode]?['moduleHint'] ?? 'Enter a module name (e.g. Login, Dashboard)';
  String get editModule => _localizedValues[locale.languageCode]?['editModule'] ?? 'Edit Module';
  String get removeModule => _localizedValues[locale.languageCode]?['removeModule'] ?? 'Remove Module';
  String get filter => _localizedValues[locale.languageCode]?['filter'] ?? 'Filter';
  String get filterByModule => _localizedValues[locale.languageCode]?['filterByModule'] ?? 'Filter by Module';
  String get allModules => _localizedValues[locale.languageCode]?['allModules'] ?? 'All Modules';
  String get noModule => _localizedValues[locale.languageCode]?['noModule'] ?? 'No Module';
  String get dragToReorder => _localizedValues[locale.languageCode]?['dragToReorder'] ?? 'Drag to reorder steps';

  String deleteTestCaseConfirmation(String title) {
    final template = _localizedValues[locale.languageCode]?['deleteTestCaseConfirmation'] ?? 
      'Are you sure you want to delete "{title}"? This action cannot be undone.';
    return template.replaceAll('{title}', title);
  }
  
  String steps(int count) {
    final template = _localizedValues[locale.languageCode]?['steps'] ?? 'Steps: {count}';
    return template.replaceAll('{count}', count.toString());
  }
  
  String createdOn(String date) {
    final template = _localizedValues[locale.languageCode]?['createdOn'] ?? 'Created on {date}';
    return template.replaceAll('{date}', date);
  }
  
  String lastExecutedOn(String date) {
    final template = _localizedValues[locale.languageCode]?['lastExecutedOn'] ?? 'Last executed on {date}';
    return template.replaceAll('{date}', date);
  }
  
  String errorSaving(String error) {
    final template = _localizedValues[locale.languageCode]?['errorSaving'] ?? 'Error saving: {error}';
    return template.replaceAll('{error}', error);
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}