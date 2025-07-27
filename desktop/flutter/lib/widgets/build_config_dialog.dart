import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/packaroo_project.dart';
import '../utils/build_validator.dart';

class BuildConfigDialog extends StatefulWidget {
  final PackarooProject project;

  const BuildConfigDialog({
    super.key,
    required this.project,
  });

  @override
  State<BuildConfigDialog> createState() => _BuildConfigDialogState();
}

class _BuildConfigDialogState extends State<BuildConfigDialog> {
  late PackarooProject _project;
  final _formKey = GlobalKey<FormState>();
  final _moduleController = TextEditingController();

  // List of common Java modules for easy selection
  final List<String> _commonModules = [
    'java.base',
    'java.desktop',
    'java.logging',
    'java.management',
    'java.sql',
    'java.xml',
    'java.net.http',
    'jdk.crypto.ec',
    'jdk.localedata',
    'jdk.zipfs',
  ];

  // Get supported package types for current platform
  List<DropdownMenuItem<String>> get _supportedPackageTypes {
    final List<DropdownMenuItem<String>> items = [
      const DropdownMenuItem(
          value: 'app-image', child: Text('App Image (Universal)')),
    ];

    if (Platform.isLinux) {
      items.addAll([
        const DropdownMenuItem(
            value: 'deb', child: Text('DEB Package (Linux)')),
        const DropdownMenuItem(
            value: 'rpm', child: Text('RPM Package (Linux)')),
      ]);
    } else if (Platform.isMacOS) {
      items.addAll([
        const DropdownMenuItem(
            value: 'dmg', child: Text('DMG Package (macOS)')),
        const DropdownMenuItem(
            value: 'pkg', child: Text('PKG Package (macOS)')),
      ]);
    } else if (Platform.isWindows) {
      items.addAll([
        const DropdownMenuItem(
            value: 'msi', child: Text('MSI Package (Windows)')),
        const DropdownMenuItem(
            value: 'exe', child: Text('EXE Package (Windows)')),
      ]);
    }

    return items;
  }

  String get _defaultPackageType {
    // Default to app-image, but ensure the current selection is valid for the platform
    if (_project.packageType.isEmpty) return 'app-image';

    final supportedTypes =
        _supportedPackageTypes.map((item) => item.value).toList();
    if (supportedTypes.contains(_project.packageType)) {
      return _project.packageType;
    }

    return 'app-image'; // Fallback to universal type
  }

  @override
  void initState() {
    super.initState();
    // Create a copy of the project for editing
    _project = PackarooProject(
      id: widget.project.id,
      name: widget.project.name,
      description: widget.project.description,
      projectPath: widget.project.projectPath,
      outputPath: widget.project.outputPath,
      jarPath: widget.project.jarPath,
      mainClass: widget.project.mainClass,
      appName: widget.project.appName,
      appVersion: widget.project.appVersion,
      appDescription: widget.project.appDescription,
      appVendor: widget.project.appVendor,
      appCopyright: widget.project.appCopyright,
      iconPath: widget.project.iconPath,
      packageType: widget.project.packageType,
      jdkPath: widget.project.jdkPath,
      jvmOptions: List.from(widget.project.jvmOptions),
      appArguments: List.from(widget.project.appArguments),
      useJlink: widget.project.useJlink,
      includeAllModules: widget.project.includeAllModules,
      additionalModules: List.from(widget.project.additionalModules),
      modulePath: widget.project.modulePath,
      compress: widget.project.compress,
      noHeaderFiles: widget.project.noHeaderFiles,
      noManPages: widget.project.noManPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Symbols.settings),
          const SizedBox(width: 12),
          Text('Build Configuration'),
        ],
      ),
      content: SizedBox(
        width: 700,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Project: ${widget.project.name}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),

                // App Icon Section
                _buildAppIconSection(),
                const SizedBox(height: 24),

                // Package Type
                _buildPackageTypeSection(),
                const SizedBox(height: 24),

                // Module Management
                _buildModuleManagementSection(),
                const SizedBox(height: 24),

                // JVM Options
                _buildJVMOptionsSection(),
                const SizedBox(height: 24),

                // JLink Options
                _buildJLinkOptionsSection(),
                const SizedBox(height: 24),

                // Output Options
                _buildOutputOptionsSection(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: const Icon(Symbols.play_arrow),
          label: const Text('Start Build'),
          onPressed: _startBuild,
        ),
      ],
    );
  }

  Widget _buildAppIconSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Application Icon',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Icon preview
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _project.iconPath.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Image.file(
                            File(_project.iconPath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Symbols.image_not_supported);
                            },
                          ),
                        )
                      : const Icon(Symbols.image, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _project.iconPath.isEmpty
                            ? 'No icon selected'
                            : 'Icon: ${_project.iconPath.split('/').last}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Symbols.folder_open),
                            label: const Text('Select Icon'),
                            onPressed: _selectIcon,
                          ),
                          if (_project.iconPath.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              icon: const Icon(Symbols.clear),
                              label: const Text('Remove'),
                              onPressed: () {
                                setState(() {
                                  _project.iconPath = '';
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: PNG, ICO, or ICNS format. Size: 256x256 or larger.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleManagementSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Java Modules',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Switch(
                  value: _project.includeAllModules,
                  onChanged: (value) {
                    setState(() {
                      _project.includeAllModules = value;
                      if (value) {
                        // Clear individual modules when "include all" is enabled
                        _project.additionalModules.clear();
                      }
                    });
                  },
                ),
                const SizedBox(width: 8),
                const Text('Include All Modules'),
              ],
            ),
            const SizedBox(height: 12),
            if (!_project.includeAllModules) ...[
              // Add module input
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _moduleController,
                      decoration: const InputDecoration(
                        labelText: 'Add Module',
                        hintText: 'e.g., java.base, java.desktop',
                        border: OutlineInputBorder(),
                      ),
                      onFieldSubmitted: _addModule,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Symbols.add),
                    onPressed: () => _addModule(_moduleController.text),
                    tooltip: 'Add Module',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Common modules
              Text(
                'Common Modules:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _commonModules.map((module) {
                  final isSelected =
                      _project.additionalModules.contains(module);
                  return FilterChip(
                    label: Text(module),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          if (!_project.additionalModules.contains(module)) {
                            _project.additionalModules.add(module);
                          }
                        } else {
                          _project.additionalModules.remove(module);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              if (_project.additionalModules.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Selected Modules:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _project.additionalModules.map((module) {
                    return Chip(
                      label: Text(module),
                      onDeleted: () {
                        setState(() {
                          _project.additionalModules.remove(module);
                        });
                      },
                      deleteIcon: const Icon(Symbols.close, size: 18),
                    );
                  }).toList(),
                ),
              ],
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Symbols.info,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'All available modules will be included in the runtime. This creates a larger but more compatible application.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Package Type',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.info,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Running on ${Platform.operatingSystem}. Only ${Platform.operatingSystem} package types are available.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _defaultPackageType,
              decoration: const InputDecoration(
                labelText: 'Package Type',
                border: OutlineInputBorder(),
              ),
              items: _supportedPackageTypes,
              onChanged: (value) {
                setState(() {
                  _project.packageType = value ?? 'app-image';
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJVMOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'JVM Options',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Symbols.add),
                  onPressed: _addJVMOption,
                  tooltip: 'Add JVM Option',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_project.jvmOptions.isEmpty)
              Text(
                'No JVM options configured',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              )
            else
              ..._project.jvmOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: option,
                          decoration: InputDecoration(
                            labelText: 'JVM Option ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _project.jvmOptions[index] = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Symbols.delete),
                        onPressed: () => _removeJVMOption(index),
                        tooltip: 'Remove Option',
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildJLinkOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JLink Options',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Symbols.lightbulb,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'For most JAR files (especially Spring Boot), disable JLink. Use JLink only for modular Java applications.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use JLink'),
              subtitle: const Text('Create custom runtime with JLink'),
              value: _project.useJlink,
              onChanged: (value) {
                setState(() {
                  _project.useJlink = value;
                });
              },
            ),
            if (_project.useJlink) ...[
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Include All Modules'),
                subtitle: const Text('Include all available modules'),
                value: _project.includeAllModules,
                onChanged: (value) {
                  setState(() {
                    _project.includeAllModules = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('Compress'),
                subtitle: const Text('Compress the runtime image'),
                value: _project.compress,
                onChanged: (value) {
                  setState(() {
                    _project.compress = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('No Header Files'),
                subtitle: const Text('Exclude header files'),
                value: _project.noHeaderFiles,
                onChanged: (value) {
                  setState(() {
                    _project.noHeaderFiles = value;
                  });
                },
              ),
              SwitchListTile(
                title: const Text('No Man Pages'),
                subtitle: const Text('Exclude manual pages'),
                value: _project.noManPages,
                onChanged: (value) {
                  setState(() {
                    _project.noManPages = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOutputOptionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Output Options',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: _project.outputPath,
              decoration: const InputDecoration(
                labelText: 'Output Directory',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Symbols.folder_open),
              ),
              onChanged: (value) {
                _project.outputPath = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Output directory is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addJVMOption() {
    setState(() {
      _project.jvmOptions.add('');
    });
  }

  void _removeJVMOption(int index) {
    setState(() {
      _project.jvmOptions.removeAt(index);
    });
  }

  void _startBuild() {
    if (_formKey.currentState?.validate() ?? false) {
      // Validate the project before starting build
      final errors = BuildValidator.validateProject(_project);

      if (errors.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Symbols.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Validation Errors'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Please fix the following issues before building:'),
                const SizedBox(height: 12),
                ...errors.map((error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Symbols.error,
                              size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(child: Text(error)),
                        ],
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      // Get recommendations
      final recommendations = BuildValidator.getBuildRecommendations(_project);

      if (recommendations.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Symbols.lightbulb, color: Colors.blue),
                SizedBox(width: 8),
                Text('Build Recommendations'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Consider these improvements:'),
                const SizedBox(height: 12),
                ...recommendations.map((rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Symbols.info,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          Expanded(child: Text(rec)),
                        ],
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(_project);
                },
                child: const Text('Build Anyway'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Review Project'),
              ),
            ],
          ),
        );
      } else {
        Navigator.of(context).pop(_project);
      }
    }
  }

  Future<void> _selectIcon() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'ico', 'icns', 'jpg', 'jpeg'],
        dialogTitle: 'Select Application Icon',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _project.iconPath = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select icon: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _addModule(String module) {
    final trimmedModule = module.trim();
    if (trimmedModule.isNotEmpty &&
        !_project.additionalModules.contains(trimmedModule)) {
      setState(() {
        _project.additionalModules.add(trimmedModule);
        _moduleController.clear();
      });
    }
  }

  @override
  void dispose() {
    _moduleController.dispose();
    super.dispose();
  }
}
