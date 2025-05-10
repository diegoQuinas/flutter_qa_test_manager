import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String THEME_MODE = 'themeMode';
  
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  ThemeProvider() {
    _loadSavedTheme();
  }
  
  // Cargar el tema guardado
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeMode = prefs.getString(THEME_MODE);
    
    if (savedThemeMode != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.toString() == savedThemeMode,
        orElse: () => ThemeMode.system,
      );
      notifyListeners();
    }
  }
  
  // Cambiar el tema
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(THEME_MODE, mode.toString());
  }
  
  // Alternar entre tema claro y oscuro
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.dark 
        ? ThemeMode.light 
        : ThemeMode.dark;
    await setThemeMode(newMode);
  }
  
  // Obtener el tema actual
  ThemeData getTheme(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isSystemDark = brightness == Brightness.dark;
    
    switch (_themeMode) {
      case ThemeMode.system:
        return isSystemDark ? AppTheme.darkTheme() : AppTheme.lightTheme();
      case ThemeMode.light:
        return AppTheme.lightTheme();
      case ThemeMode.dark:
        return AppTheme.darkTheme();
    }
  }
}
