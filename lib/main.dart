import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';
import 'screens/splash_screen.dart';
import 'services/test_provider.dart';
import 'services/language_provider.dart';
import 'services/theme_provider.dart';
import 'utils/theme.dart';
import 'utils/app_localizations.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize sqflite_ffi
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory for desktop platforms
    databaseFactory = databaseFactoryFfi;
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TestProvider()),
        ChangeNotifierProvider(create: (context) => LanguageProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return MaterialApp(
      title: 'QA Test Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeProvider.themeMode,
      
      // Configuración de localización
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      
      home: const SplashScreen(),
    );
  }
}

// Esta clase ya no es necesaria ya que iniciamos directamente desde el SplashScreen
// Mantenemos el código comentado para referencia
/*
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Inicializar el test provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TestProvider>(context, listen: false).init();
    });

    return const TestCaseListScreen();
  }
}
*/

// Extensiones útiles para la aplicación
extension StringExtension on String {
  String capitalizeCustom() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  String get toTitleCase {
    return split(' ').map((str) => str.capitalizeCustom()).join(' ');
  }
}

// Extension for searching in lists
extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}