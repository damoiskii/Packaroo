import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../models/packaroo_project.dart';
import '../providers/project_provider.dart';
import '../services/jar_analyzer_service.dart';
import '../utils/string_utils.dart';

class ProjectEditScreen extends StatefulWidget {
  final PackarooProject? project;

  const ProjectEditScreen({super.key, this.project});

  @override
  State<ProjectEditScreen> createState() => _ProjectEditScreenState();
}

class _ProjectEditScreenState extends State<ProjectEditScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _jarPathController;
  late final TextEditingController _mainClassController;
  late final TextEditingController _appNameController;
  late final TextEditingController _appVersionController;
  late final TextEditingController _appVendorController;
  late final TextEditingController _outputPathController;
  late final TextEditingController _jdkPathController;

  final _formKey = GlobalKey<FormState>();
  final JarAnalyzerService _jarAnalyzer = JarAnalyzerService();

  bool _isModified = false;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();

    final project = widget.project;

    _nameController = TextEditingController(text: project?.name ?? '');
    _descriptionController =
        TextEditingController(text: project?.description ?? '');
    _jarPathController = TextEditingController(text: project?.jarPath ?? '');
    _mainClassController =
        TextEditingController(text: project?.mainClass ?? '');
    _appNameController = TextEditingController(text: project?.appName ?? '');
    _appVersionController =
        TextEditingController(text: project?.appVersion ?? '1.0.0');
    _appVendorController =
        TextEditingController(text: project?.appVendor ?? '');
    _outputPathController =
        TextEditingController(text: project?.outputPath ?? '');
    _jdkPathController = TextEditingController(text: project?.jdkPath ?? '');

    // Add listeners to track modifications
    _addModificationListeners();
  }

  void _addModificationListeners() {
    for (final controller in [
      _nameController,
      _descriptionController,
      _jarPathController,
      _mainClassController,
      _appNameController,
      _appVersionController,
      _appVendorController,
      _outputPathController,
      _jdkPathController,
    ]) {
      controller.addListener(() {
        if (!_isModified) {
          setState(() {
            _isModified = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _jarPathController.dispose();
    _mainClassController.dispose();
    _appNameController.dispose();
    _appVersionController.dispose();
    _appVendorController.dispose();
    _outputPathController.dispose();
    _jdkPathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project == null ? 'New Project' : 'Edit Project'),
        actions: [
          OutlinedButton(
            onPressed: () => _handleCancel(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _isFormValid() ? _handleSave : null,
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // JAR File Selection at the top
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: 300,
                      child: ElevatedButton.icon(
                        onPressed: _pickAndAnalyzeJar,
                        icon: _isAnalyzing
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.upload_file),
                        label: Text(
                            _isAnalyzing ? 'Analyzing...' : 'Select JAR File'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _jarPathController,
                      label: 'JAR Path',
                      hint: 'Path to the JAR file',
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'JAR file is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Two-column layout
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _nameController,
                            label: 'Project Name',
                            hint: 'Enter project name',
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Project name is required';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              // Auto-update app name when project name changes
                              if (_appNameController.text.isEmpty ||
                                  _appNameController.text ==
                                      StringUtils.toTitleCase(
                                          _nameController.text)) {
                                _appNameController.text =
                                    StringUtils.toTitleCase(value);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Description',
                            hint: 'Enter project description (optional)',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _mainClassController,
                            label: 'Main Class',
                            hint: 'e.g., com.example.MainClass',
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Main class is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Right column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Application Details',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(
                            controller: _appNameController,
                            label: 'Application Name',
                            hint: 'Display name for the application',
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Application name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _appVersionController,
                            label: 'Version',
                            hint: 'e.g., 1.0.0',
                            isRequired: true,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Version is required';
                              }
                              if (!StringUtils.isValidVersion(value.trim())) {
                                return 'Invalid version format (e.g., 1.0.0)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _appVendorController,
                            label: 'Vendor',
                            hint: 'Organization or developer name',
                          ),
                          const SizedBox(height: 16),
                          _buildFilePickerField(
                            controller: _outputPathController,
                            label: 'Output Directory',
                            hint: 'Select output directory',
                            isRequired: true,
                            fileType: 'directory',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Output directory is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildFilePickerField(
                            controller: _jdkPathController,
                            label: 'JDK Path (Optional)',
                            hint: 'Select JDK installation directory',
                            fileType: 'directory',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    int maxLines = 1,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildFilePickerField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool isRequired = false,
    required String fileType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hint,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        suffixIcon: IconButton(
          icon: const Icon(Icons.folder_open),
          onPressed: () => _pickFile(controller, fileType),
        ),
      ),
      readOnly: true,
    );
  }

  Future<void> _pickFile(
      TextEditingController controller, String fileType) async {
    try {
      String? selectedPath;

      if (fileType == 'directory') {
        selectedPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select Directory',
        );
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [fileType],
          dialogTitle: 'Select ${fileType.toUpperCase()} file',
        );
        selectedPath = result?.files.single.path;
      }

      if (selectedPath != null) {
        controller.text = selectedPath;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _pickAndAnalyzeJar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jar'],
        dialogTitle: 'Select JAR file to analyze',
      );

      if (result != null && result.files.single.path != null) {
        final jarPath = result.files.single.path!;
        await _analyzeJarAndPopulateFields(jarPath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to select JAR file: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _analyzeJarAndPopulateFields(String jarPath) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Analyze the JAR file
      final analysisResult = await _jarAnalyzer.analyzeJar(jarPath);

      // Auto-populate all fields with analyzed data
      setState(() {
        _jarPathController.text = jarPath;

        // Format app name to title case
        final formattedAppName =
            StringUtils.toTitleCase(analysisResult.suggestedAppName);

        // Only update fields if they're currently empty (don't override user changes)
        if (_nameController.text.isEmpty) {
          _nameController.text = formattedAppName;
        }

        if (_mainClassController.text.isEmpty) {
          _mainClassController.text = analysisResult.mainClass;
        }

        if (_appNameController.text.isEmpty) {
          _appNameController.text = formattedAppName;
        }

        if (_appVersionController.text.isEmpty ||
            _appVersionController.text == '1.0.0') {
          _appVersionController.text = analysisResult.suggestedVersion;
        }

        // Always update vendor field from JAR metadata if available
        final jarVendor = analysisResult.suggestedVendor;
        if (jarVendor.isNotEmpty) {
          _appVendorController.text = jarVendor;
        }

        // Set default output path if empty
        if (_outputPathController.text.isEmpty) {
          final jarDir = jarPath.substring(0, jarPath.lastIndexOf('/'));
          _outputPathController.text = '$jarDir/dist';
        }

        _isAnalyzing = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'JAR analyzed successfully! Found main class: ${analysisResult.mainClass}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to analyze JAR: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  bool _isFormValid() {
    return _nameController.text.trim().isNotEmpty &&
        _jarPathController.text.trim().isNotEmpty &&
        _mainClassController.text.trim().isNotEmpty &&
        _appNameController.text.trim().isNotEmpty &&
        _appVersionController.text.trim().isNotEmpty &&
        _outputPathController.text.trim().isNotEmpty &&
        StringUtils.isValidVersion(_appVersionController.text.trim());
  }

  void _handleCancel() {
    if (_isModified) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Unsaved Changes'),
          content: const Text(
              'You have unsaved changes. Are you sure you want to cancel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Editing'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard Changes'),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true) {
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void _handleSave() {
    // Custom validation for JAR path since we removed the TextFormField
    if (_jarPathController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a JAR file'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final projectProvider = context.read<ProjectProvider>();

      final project = PackarooProject(
        id: widget.project?.id,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        projectPath: '', // Will be set by the provider
        outputPath: _outputPathController.text.trim(),
        jarPath: _jarPathController.text.trim(),
        mainClass: _mainClassController.text.trim(),
        appName: _appNameController.text.trim(),
        appVersion: _appVersionController.text.trim(),
        appVendor: _appVendorController.text.trim(),
        jdkPath: _jdkPathController.text.trim(),
        additionalModules: widget.project?.additionalModules ?? [],
        jvmOptions: widget.project?.jvmOptions ?? [],
        packageType: widget.project?.packageType ?? 'app-image',
        createdDate: widget.project?.createdDate,
        lastModified: DateTime.now(),
      );

      if (widget.project == null) {
        projectProvider.createProject(project);
      } else {
        projectProvider.updateProject(project);
      }

      Navigator.of(context).pop(project);
    }
  }
}
