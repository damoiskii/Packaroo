import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/project_provider.dart';
import '../providers/build_provider.dart';

class ProjectDetails extends StatelessWidget {
  const ProjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, projectProvider, child) {
        final project = projectProvider.selectedProject;
        if (project == null) {
          return const Center(
            child: Text('No project selected'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Symbols.package_2,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.displayName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        if (project.description.isNotEmpty)
                          Text(
                            project.description,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Info Cards
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      icon: Symbols.info,
                      title: 'Version',
                      value: project.appVersion,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoCard(
                      icon: Symbols.category,
                      title: 'Package Type',
                      value: project.packageType,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer<BuildProvider>(
                      builder: (context, buildProvider, child) {
                        final isBuilding =
                            buildProvider.isBuildingProject(project.id);
                        final builds =
                            buildProvider.getBuildsForProject(project.id);
                        final lastBuild =
                            builds.isNotEmpty ? builds.first : null;

                        String status = 'Not built';
                        Color? statusColor;

                        if (isBuilding) {
                          status = 'Building...';
                          statusColor = Theme.of(context).colorScheme.primary;
                        } else if (lastBuild != null) {
                          if (lastBuild.isCompleted) {
                            status = 'Success';
                            statusColor = Colors.green;
                          } else if (lastBuild.isFailed) {
                            status = 'Failed';
                            statusColor = Colors.red;
                          } else if (lastBuild.isCancelled) {
                            status = 'Cancelled';
                            statusColor = Colors.orange;
                          }
                        }

                        return _InfoCard(
                          icon: Symbols.build,
                          title: 'Status',
                          value: status,
                          valueColor: statusColor,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Configuration Sections
              _buildSection(
                context,
                'Basic Configuration',
                [
                  _buildDetailRow('Project Name', project.name),
                  _buildDetailRow('Main Class', project.mainClass),
                  _buildDetailRow('JAR File', project.jarPath),
                  _buildDetailRow('Output Path', project.outputPath),
                ],
              ),

              const SizedBox(height: 16),

              _buildSection(
                context,
                'Application Metadata',
                [
                  _buildDetailRow('Application Name',
                      project.appName.isNotEmpty ? project.appName : 'Not set'),
                  _buildDetailRow('Version', project.appVersion),
                  _buildDetailRow(
                      'Vendor',
                      project.appVendor.isNotEmpty
                          ? project.appVendor
                          : 'Not set'),
                  _buildDetailRow(
                      'Copyright',
                      project.appCopyright.isNotEmpty
                          ? project.appCopyright
                          : 'Not set'),
                  if (project.iconPath.isNotEmpty)
                    _buildDetailRow('Icon', project.iconPath),
                ],
              ),

              const SizedBox(height: 16),

              _buildSection(
                context,
                'Advanced Options',
                [
                  _buildDetailRow('Use JLink', project.useJlink ? 'Yes' : 'No'),
                  if (project.jdkPath.isNotEmpty)
                    _buildDetailRow('JDK Path', project.jdkPath),
                  if (project.modulePath.isNotEmpty)
                    _buildDetailRow('Module Path', project.modulePath),
                  if (project.jvmOptions.isNotEmpty)
                    _buildDetailRow(
                        'JVM Options', project.jvmOptions.join(', ')),
                  if (project.appArguments.isNotEmpty)
                    _buildDetailRow(
                        'App Arguments', project.appArguments.join(', ')),
                ],
              ),

              const SizedBox(height: 24),

              // Build History
              Consumer<BuildProvider>(
                builder: (context, buildProvider, child) {
                  final builds = buildProvider.getBuildsForProject(project.id);

                  if (builds.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Symbols.history,
                              size: 48,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No build history',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Build this project to see history',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Symbols.history,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Recent Builds',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${builds.length} builds',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        ...builds.take(5).map((build) => ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getBuildStatusColor(build.status, context),
                                radius: 12,
                                child: Icon(
                                  _getBuildStatusIcon(build.status),
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(build.currentStep),
                              subtitle: Text(
                                'Started ${_formatDate(build.startTime)}${build.duration != null ? ' • ${build.durationString}' : ''}',
                              ),
                              trailing: build.isRunning
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: build.progress,
                                      ),
                                    )
                                  : null,
                            )),
                        if (builds.length > 5)
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Center(
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Navigate to full build history
                                },
                                child: const Text('View all builds'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBuildStatusColor(dynamic status, BuildContext context) {
    switch (status.toString()) {
      case 'BuildStatus.completed':
        return Colors.green;
      case 'BuildStatus.failed':
        return Colors.red;
      case 'BuildStatus.cancelled':
        return Colors.orange;
      case 'BuildStatus.running':
        return Theme.of(context).colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getBuildStatusIcon(dynamic status) {
    switch (status.toString()) {
      case 'BuildStatus.completed':
        return Symbols.check;
      case 'BuildStatus.failed':
        return Symbols.close;
      case 'BuildStatus.cancelled':
        return Symbols.cancel;
      case 'BuildStatus.running':
        return Symbols.play_arrow;
      default:
        return Symbols.schedule;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: valueColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
