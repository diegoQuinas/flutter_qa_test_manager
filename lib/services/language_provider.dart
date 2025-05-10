import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String LANGUAGE_CODE = 'languageCode';
  static const String LANGUAGE_COUNTRY_CODE = 'languageCountryCode';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  LanguageProvider() {
    // Cargar el idioma guardado al inicializar
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    
    final String languageCode = prefs.getString(LANGUAGE_CODE) ?? 'en';
    final String? countryCode = prefs.getString(LANGUAGE_COUNTRY_CODE);
    
    _setLocale(languageCode, countryCode);
  }

  // Cambiar idioma - devuelve true si el idioma cambió, false si ya está en ese idioma
  Future<bool> changeLanguage(String languageCode, {String? countryCode}) async {
    // Si el idioma es el mismo, no hacemos nada
    if (_locale.languageCode == languageCode && 
        _locale.countryCode == countryCode) {
      return false;
    }
    
    // Guardar en SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LANGUAGE_CODE, languageCode);
    
    if (countryCode != null) {
      await prefs.setString(LANGUAGE_COUNTRY_CODE, countryCode);
    } else {
      await prefs.remove(LANGUAGE_COUNTRY_CODE);
    }
    
    // Actualizar locale
    _setLocale(languageCode, countryCode);
    return true;
  }

  void _setLocale(String languageCode, String? countryCode) {
    _locale = countryCode == null || countryCode.isEmpty 
      ? Locale(languageCode) 
      : Locale(languageCode, countryCode);
    
    notifyListeners();
  }
}