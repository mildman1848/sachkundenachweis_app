import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Design-Auswahl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16),
          ...AppThemeMode.values.map((mode) {
            return Card(
              color: themeNotifier.themeMode == mode
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.15)
                  : null,
              child: ListTile(
                leading: Icon(_iconForTheme(mode)),
                title: Text(_themeName(mode)),
                trailing: themeNotifier.themeMode == mode
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary)
                    : null,
                onTap: () => themeNotifier.themeMode = mode,
              ),
            );
          }),
        ],
      ),
    );
  }
}

String _themeName(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return 'Automatisch (System)';
    case AppThemeMode.calmNature:
      return 'Calm Nature';
    case AppThemeMode.brightMinimal:
      return 'Bright Minimal';
    case AppThemeMode.darkElegant:
      return 'Dark Elegant';
  }
}

IconData _iconForTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.system:
      return Icons.brightness_auto;
    case AppThemeMode.calmNature:
      return Icons.nature_people;
    case AppThemeMode.brightMinimal:
      return Icons.wb_sunny;
    case AppThemeMode.darkElegant:
      return Icons.nightlight_round;
  }
}
