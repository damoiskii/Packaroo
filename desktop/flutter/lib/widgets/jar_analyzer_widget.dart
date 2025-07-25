import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../services/jar_analyzer_service.dart';
import '../services/package_service.dart';
import '../providers/project_provider.dart';

class JarAnalyzerWidget extends StatefulWidget {
  const JarAnalyzerWidget({super.key});

  @override
  State<JarAnalyzerWidget> createState() => _JarAnalyzerWidgetState();
}

class _JarAnalyzerWidgetState extends State<JarAnalyzerWidget> {
  final JarAnalyzerService _analyzer = JarAnalyzerService();
  final PackageService _packageService = PackageService();

  String? _selectedJarPath;
  JarAnalysisResult? _analysisResult;
  bool _isAnalyzing = false;
  String? _errorMessage;

  Future<void> _pickAndAnalyzeJar() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jar'],
        dialogTitle: 'Select JAR file to analyze',
      );

      if (result != null && result.files.single.path != null) {
        final jarPath = result.files.single.path!;
        await _analyzeJar(jarPath);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to pick file: $e';
      });
    }
  }

  Future<void> _analyzeJar(String jarPath) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _selectedJarPath = jarPath;
    });

    try {
      final result = await _analyzer.analyzeJar(jarPath);
      setState(() {
        _analysisResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis failed: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _createProjectFromJar() async {
    if (_analysisResult == null) return;

    try {
      final project = await _packageService
          .analyzeAndCreateProject(_analysisResult!.jarPath);

      if (mounted) {
        await context.read<ProjectProvider>().createProject(project);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project "${project.name}" created successfully'),
            action: SnackBarAction(
              label: 'View',
              onPressed: () {
                Navigator.of(context).pop(project);
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create project: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'JAR File Analyzer',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Analyze a JAR file to extract metadata and create a new project',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // File picker
            ElevatedButton.icon(
              onPressed: _isAnalyzing ? null : _pickAndAnalyzeJar,
              icon: const Icon(Icons.folder_open),
              label: const Text('Select JAR File'),
            ),

            if (_selectedJarPath != null) ...[
              const SizedBox(height: 16),
              Text(
                'Selected: ${_selectedJarPath!.split('/').last}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            // Analysis progress
            if (_isAnalyzing) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Analyzing JAR file...'),
            ],

            // Error message
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Analysis results
            if (_analysisResult != null) ...[
              const SizedBox(height: 16),
              _buildAnalysisResults(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisResults() {
    final result = _analysisResult!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analysis Results',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        // Basic info
        _buildInfoRow('File Name', result.fileName),
        _buildInfoRow('File Size', result.formattedFileSize),
        _buildInfoRow('Main Class', result.mainClass),
        _buildInfoRow('Suggested App Name', result.suggestedAppName),
        _buildInfoRow('Suggested Version', result.suggestedVersion),
        if (result.suggestedVendor.isNotEmpty)
          _buildInfoRow('Suggested Vendor', result.suggestedVendor),

        const SizedBox(height: 16),

        // Modules
        if (result.modules.isNotEmpty) ...[
          Text(
            'Required Modules (${result.modules.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: result.modules
                .take(10)
                .map((module) => Chip(
                      label: Text(module),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                    ))
                .toList(),
          ),
          if (result.modules.length > 10)
            Text(
              '... and ${result.modules.length - 10} more',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
        ],

        // Dependencies
        if (result.dependencies.isNotEmpty) ...[
          Text(
            'Dependencies (${result.dependencies.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 100),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: result.dependencies
                    .take(20)
                    .map(
                      (dep) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          dep,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          if (result.dependencies.length > 20)
            Text(
              '... and ${result.dependencies.length - 20} more',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const SizedBox(height: 16),
        ],

        // JAR info
        if (result.jarInfo.isNotEmpty) ...[
          Text(
            'JAR Information',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ...result.jarInfo.entries
              .map((entry) => _buildInfoRow(entry.key, entry.value.toString())),
          const SizedBox(height: 16),
        ],

        // Create project button
        Center(
          child: FilledButton.icon(
            onPressed: _createProjectFromJar,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Create Project from JAR'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
