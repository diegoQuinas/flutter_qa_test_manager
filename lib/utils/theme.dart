import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colores principales de la aplicación - azul/cyan
  static const Color primaryColor = Color(0xFF00BCD4); // Cyan
  static const Color primaryColorDark = Color(0xFF0097A7); // Cyan oscuro
  static const Color accentColor = Color(0xFF03A9F4); // Azul claro
  static const Color secondaryColor = Color(0xFF2196F3); // Azul

  // Colores para el modo oscuro
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);

  // Método para obtener el tema claro
  static ThemeData lightTheme() {
    return FlexThemeData.light(
      scheme: FlexScheme.aquaBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 9,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        inputDecoratorRadius: 12.0,
        cardRadius: 12.0,
        dialogRadius: 16.0,
        bottomSheetRadius: 24.0,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarBackgroundSchemeColor: SchemeColor.background,
        chipRadius: 8.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        toggleButtonsRadius: 12.0,
        appBarCenterTitle: true,
        bottomNavigationBarElevation: 3.0,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailBackgroundSchemeColor: SchemeColor.background,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  // Método para obtener el tema oscuro
  static ThemeData darkTheme() {
    return FlexThemeData.dark(
      scheme: FlexScheme.aquaBlue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        appBarBackgroundSchemeColor: SchemeColor.background,
        navigationBarSelectedLabelSchemeColor: SchemeColor.primary,
        navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationBarSelectedIconSchemeColor: SchemeColor.primary,
        navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationBarIndicatorSchemeColor: SchemeColor.primary,
        navigationBarBackgroundSchemeColor: SchemeColor.background,
        inputDecoratorRadius: 12.0,
        cardRadius: 12.0,
        dialogRadius: 16.0,
        bottomSheetRadius: 24.0,
        chipRadius: 8.0,
        elevatedButtonRadius: 12.0,
        outlinedButtonRadius: 12.0,
        textButtonRadius: 12.0,
        toggleButtonsRadius: 12.0,
        appBarCenterTitle: true,
        bottomNavigationBarElevation: 3.0,
        navigationRailSelectedLabelSchemeColor: SchemeColor.primary,
        navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
        navigationRailSelectedIconSchemeColor: SchemeColor.primary,
        navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
        navigationRailBackgroundSchemeColor: SchemeColor.background,
      ),
      darkIsTrueBlack: true,
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
  }

  // Estilos de texto para referenciar en toda la aplicación
  static TextStyle get headingStyle => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      );

  static TextStyle get subheadingStyle => const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get bodyStyle => const TextStyle(
        fontSize: 16,
        letterSpacing: 0.2,
      );

  static TextStyle get smallStyle => const TextStyle(
        fontSize: 14,
        letterSpacing: 0.1,
      );

  // Estilo para tarjetas destacadas
  static BoxDecoration get cardDecoration => BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Estilo para los botones principales
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );

  // Estilo para los botones secundarios
  static ButtonStyle get secondaryButtonStyle => OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      );
}