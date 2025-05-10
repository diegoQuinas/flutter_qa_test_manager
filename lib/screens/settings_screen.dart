import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/language_provider.dart';
import '../services/theme_provider.dart';
import '../utils/app_localizations.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar animaciones
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [Colors.blueGrey.shade900, Colors.black]
                  : [Colors.blue.shade50, Colors.white],
              stops: const [0.0, 0.7],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeader(isDark),
              const SizedBox(height: 24),
              _buildSectionTitle('Apariencia'),
              const SizedBox(height: 12),
              _buildThemeSelector(themeProvider),
              const SizedBox(height: 24),
              _buildSectionTitle(AppLocalizations.of(context).language),
              const SizedBox(height: 12),
              _buildLanguageSelector(),
              const SizedBox(height: 24),
              _buildSectionTitle('Acerca de'),
              const SizedBox(height: 12),
              _buildAboutSection(isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.settings,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).settings,
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personaliza tu experiencia',
                    style: AppTheme.smallStyle.copyWith(
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
      child: Text(
        title,
        style: AppTheme.subheadingStyle.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeSelector(ThemeProvider themeProvider) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final isSystem = themeProvider.themeMode == ThemeMode.system;
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tema de la aplicación',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    title: 'Claro',
                    icon: Icons.light_mode,
                    selected: themeProvider.themeMode == ThemeMode.light,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.light),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    title: 'Oscuro',
                    icon: Icons.dark_mode,
                    selected: themeProvider.themeMode == ThemeMode.dark,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    title: 'Sistema',
                    icon: Icons.settings_suggest,
                    selected: themeProvider.themeMode == ThemeMode.system,
                    onTap: () => themeProvider.setThemeMode(ThemeMode.system),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                'Modo oscuro',
                style: AppTheme.bodyStyle,
              ),
              subtitle: Text(
                isSystem ? 'Usar configuración del sistema' : (isDark ? 'Activado' : 'Desactivado'),
                style: AppTheme.smallStyle,
              ),
              value: isDark,
              onChanged: isSystem ? null : (value) {
                themeProvider.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
              },
              secondary: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? Colors.white70 : Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Seleccionar idioma',
                      style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageOption(
                        title: AppLocalizations.of(context).english,
                        languageCode: 'en',
                        flagEmoji: '🇺🇸',
                        selected: languageProvider.locale.languageCode == 'en',
                        onTap: () => languageProvider.changeLanguage('en'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLanguageOption(
                        title: AppLocalizations.of(context).spanish,
                        languageCode: 'es',
                        flagEmoji: '🇪🇸',
                        selected: languageProvider.locale.languageCode == 'es',
                        onTap: () => languageProvider.changeLanguage('es'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Los reportes se generarán en el idioma seleccionado',
                          style: AppTheme.smallStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLanguageOption({
    required String title,
    required String languageCode,
    required String flagEmoji,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(8),
          border: selected
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              flagEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : (isDark ? Colors.white70 : Colors.grey.shade700),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(bool isDark) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Acerca de',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.blueGrey.shade800 : Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_outlined,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'QA Test Manager',
                style: AppTheme.headingStyle.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Aplicación para gestionar casos de prueba de QA',
                style: AppTheme.bodyStyle,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Versión',
                  style: AppTheme.bodyStyle,
                ),
                Text(
                  '1.0.0',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desarrollado por',
                  style: AppTheme.bodyStyle,
                ),
                Text(
                  'QA Team',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Año',
                  style: AppTheme.bodyStyle,
                ),
                Text(
                  '2025',
                  style: AppTheme.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}