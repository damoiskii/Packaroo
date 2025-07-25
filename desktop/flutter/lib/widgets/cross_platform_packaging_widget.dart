import 'package:flutter/material.dart';
import '../models/packaroo_project.dart';
import '../models/build_progress.dart';
import '../services/package_service.dart';

class CrossPlatformPackagingWidget extends StatefulWidget {
  final PackarooProject project;

  const CrossPlatformPackagingWidget({
    super.key,
    required this.project,
  });

  @override
  State<CrossPlatformPackagingWidget> createState() =>
      _CrossPlatformPackagingWidgetState();
}

class _CrossPlatformPackagingWidgetState
    extends State<CrossPlatformPackagingWidget> {
  final PackageService _packageService = PackageService();
  final Set<String> _selectedPlatforms = {};
  bool _isBuilding = false;
  final List<BuildProgress> _builds = [];

  static const List<Map<String, dynamic>> _platforms = [
    {
      'id': 'windows',
      'name': 'Windows',
      'icon': Icons.desktop_windows,
      'packageTypes': ['exe', 'msi'],
      'description': 'Windows executable and installer packages',
    },
    {
      'id': 'macos',
      'name': 'macOS',
      'icon': Icons.laptop_mac,
      'packageTypes': ['dmg', 'pkg'],
      'description': 'macOS disk image and installer packages',
    },
    {
      'id': 'linux',
      'name': 'Linux',
      'icon': Icons.computer,
      'packageTypes': ['deb', 'rpm', 'app-image'],
      'description': 'Linux packages and application images',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Default to current platform
    if (Theme.of(context).platform == TargetPlatform.windows) {
      _selectedPlatforms.add('windows');
    } else if (Theme.of(context).platform == TargetPlatform.macOS) {
      _selectedPlatforms.add('macos');
    } else {
      _selectedPlatforms.add('linux');
    }
  }

  Future<void> _startCrossPlatformBuild() async {
    if (_selectedPlatforms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one platform'),
        ),
      );
      return;
    }

    setState(() {
      _isBuilding = true;
      _builds.clear();
    });

    try {
      // Start builds for all selected platforms
      final platformBuilds = await _packageService.buildForAllPlatforms(
        widget.project,
        _selectedPlatforms.toList(),
        (progress) {
          // Update the specific build in our list
          final index = _builds.indexWhere((b) => b.id == progress.id);
          if (index >= 0) {
            setState(() {
              _builds[index] = progress;
            });
          } else {
            setState(() {
              _builds.add(progress);
            });
          }
        },
      );

      setState(() {
        _builds.clear();
        _builds.addAll(platformBuilds);
        _isBuilding = false;
      });

      // Show completion message
      final successCount =
          _builds.where((b) => b.status == BuildStatus.completed).length;
      final failedCount =
          _builds.where((b) => b.status == BuildStatus.failed).length;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Build completed: $successCount successful, $failedCount failed'),
            backgroundColor: failedCount == 0
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isBuilding = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Build failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cross-Platform Packaging',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Build packages for multiple platforms',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),

        // Platform selection
        Text(
          'Target Platforms',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        ..._platforms.map((platform) => _buildPlatformCard(platform)),

        const SizedBox(height: 24),

        // Build button
        Row(
          children: [
            FilledButton.icon(
              onPressed: _isBuilding ? null : _startCrossPlatformBuild,
              icon: _isBuilding
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.build),
              label: Text(_isBuilding ? 'Building...' : 'Start Build'),
            ),
            const SizedBox(width: 16),
            Text(
              '${_selectedPlatforms.length} platform(s) selected',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),

        // Build progress
        if (_builds.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            'Build Progress',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ..._builds.map((build) => _buildProgressCard(build)),
        ],
      ],
    );
  }

  Widget _buildPlatformCard(Map<String, dynamic> platform) {
    final isSelected = _selectedPlatforms.contains(platform['id']);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: isSelected,
        onChanged: _isBuilding
            ? null
            : (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedPlatforms.add(platform['id']);
                  } else {
                    _selectedPlatforms.remove(platform['id']);
                  }
                });
              },
        title: Row(
          children: [
            Icon(platform['icon'] as IconData),
            const SizedBox(width: 8),
            Text(platform['name']),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(platform['description']),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: (platform['packageTypes'] as List<String>)
                  .map(
                    (type) => Chip(
                      label: Text(type.toUpperCase()),
                      labelStyle: Theme.of(context).textTheme.bodySmall,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildProgressCard(BuildProgress build) {
    Color? statusColor;
    IconData statusIcon;

    switch (build.status) {
      case BuildStatus.pending:
        statusColor = Theme.of(context).colorScheme.outline;
        statusIcon = Icons.schedule;
        break;
      case BuildStatus.running:
        statusColor = Theme.of(context).colorScheme.primary;
        statusIcon = Icons.play_circle;
        break;
      case BuildStatus.completed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case BuildStatus.failed:
      case BuildStatus.cancelled:
        statusColor = Theme.of(context).colorScheme.error;
        statusIcon = Icons.error;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  build.id.split('_').last, // Extract platform from build ID
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                Text(
                  build.status.name.toUpperCase(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (build.status == BuildStatus.running) ...[
              LinearProgressIndicator(
                value: build.progress,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                build.currentStep,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (build.status == BuildStatus.completed &&
                build.outputPath.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Output: ${build.outputPath}',
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (build.status == BuildStatus.failed &&
                build.logs.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  build.logs.last,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
