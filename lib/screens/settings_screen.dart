// Pfad: lib/screens/settings_screen.dart – Screen für Einstellungen, z.B. Theme-Wechsel.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Für State-Management (Best Practice: Riverpod statt Provider).
import '../theme/theme_notifier.dart'; // Theme-Notifier.

// SettingsScreen (ConsumerWidget für Riverpod, Best Practice: Stateless mit ref).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeNotifier = ref.watch(themeNotifierProvider.notifier); // Riverpod für Theme (behebt Provider.of).
    final currentMode = ref.watch(themeNotifierProvider).mode; // Aktueller Mode.

    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')), // Const.
      body: ListView(
        padding: const EdgeInsets.all(16), // Const.
        children: [
          const Text(
            'Design-Auswahl',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 16), // Const.
          ...AppThemeMode.values.map((mode) {
            final isSelected = currentMode == mode; // Aktueller Check.
            final Color base = Theme.of(context).colorScheme.secondary;

            final Color? highlight = isSelected
                ? base.withValues(alpha: 0.15) // Deprecated behoben, alpha angepasst.
                : null;

            return Semantics(  // Accessibility (Best Practice: Screen-Reader-Support).
              label: _themeName(mode),
              child: Card(
                color: highlight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(_iconForTheme(mode)),
                  title: Text(_themeName(mode)),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: base)
                      : null,
                  onTap: () => themeNotifier.setThemeMode(mode), // Setzen via Riverpod.
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// Theme-Namen (Best Practice: Helper-Funktion).
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

// Icons für Themes (Best Practice: Helper-Funktion).
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