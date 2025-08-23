import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Application Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),

              // Theme Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.palette,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Appearance',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Theme Mode'),
                        subtitle: Text(_getThemeModeDescription(
                            settingsProvider.themeMode)),
                        trailing: DropdownButton<ThemeMode>(
                          value: settingsProvider.themeMode,
                          onChanged: (ThemeMode? value) {
                            if (value != null) {
                              settingsProvider.setThemeMode(value);
                            }
                          },
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Build Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Symbols.build,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Build Settings',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Default JDK Path'),
                        subtitle: Text(
                          settingsProvider.defaultJdkPath.isEmpty
                              ? 'Not set'
                              : settingsProvider.defaultJdkPath,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Symbols.folder),
                          onPressed: () {
                            // TODO: Implement folder picker
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Default Output Path'),
                        subtitle: Text(
                          settingsProvider.defaultOutputPath.isEmpty
                              ? 'Not set'
                              : settingsProvider.defaultOutputPath,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Symbols.folder),
                          onPressed: () {
                            // TODO: Implement folder picker
                          },
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Auto Save Projects'),
                        subtitle:
                            const Text('Automatically save project changes'),
                        value: settingsProvider.autoSave,
                        onChanged: settingsProvider.setAutoSave,
                      ),
                      SwitchListTile(
                        title: const Text('Show Advanced Options'),
                        subtitle:
                            const Text('Show advanced configuration options'),
                        value: settingsProvider.showAdvancedOptions,
                        onChanged: settingsProvider.setShowAdvancedOptions,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Symbols.restart_alt),
                    label: const Text('Reset to Defaults'),
                    onPressed: () =>
                        _showResetDialog(context, settingsProvider),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Symbols.download),
                    label: const Text('Export Settings'),
                    onPressed: () {
                      // TODO: Implement export settings
                    },
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    icon: const Icon(Symbols.upload),
                    label: const Text('Import Settings'),
                    onPressed: () {
                      // TODO: Implement import settings
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getThemeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow system theme';
      case ThemeMode.light:
        return 'Always light theme';
      case ThemeMode.dark:
        return 'Always dark theme';
    }
  }

  void _showResetDialog(
      BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              settingsProvider.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}
