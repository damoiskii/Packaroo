import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/build_provider.dart';
import '../models/build_progress.dart';

class BuildMonitor extends StatelessWidget {
  const BuildMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BuildProvider>(
      builder: (context, buildProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Builds Section
              if (buildProvider.hasActiveBuilds) ...[
                Text(
                  'Active Builds',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...buildProvider.activeBuilds.values.map(
                  (build) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                radius: 12,
                                child: const Icon(
                                  Symbols.play_arrow,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  build.currentStep,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              Text(
                                '${(build.progress * 100).toStringAsFixed(1)}%',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: build.progress,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Symbols.schedule,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Started ${_formatDate(build.startTime)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () =>
                                    buildProvider.cancelBuild(build.projectId),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // Build History Section
              Row(
                children: [
                  Text(
                    'Build History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Consumer<BuildProvider>(
                    builder: (context, provider, child) {
                      final stats = provider.getBuildStatistics();
                      return Row(
                        children: [
                          _StatChip(
                            label: 'Total',
                            value: stats['total'].toString(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Success Rate',
                            value: '${stats['successRate']}%',
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          _StatChip(
                            label: 'Avg Time',
                            value: stats['averageDuration'],
                            color: Colors.blue,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Build List
              Expanded(
                child: buildProvider.buildHistory.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Symbols.history,
                              size: 64,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
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
                            const SizedBox(height: 8),
                            Text(
                              'Start building a project to see history',
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
                      )
                    : ListView.builder(
                        itemCount: buildProvider.buildHistory.length,
                        itemBuilder: (context, index) {
                          final build = buildProvider.buildHistory[index];
                          return Card(
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    _getBuildStatusColor(build.status, context),
                                radius: 16,
                                child: Icon(
                                  _getBuildStatusIcon(build.status),
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(build.currentStep),
                              subtitle: Row(
                                children: [
                                  Text(
                                      'Started ${_formatDate(build.startTime)}'),
                                  if (build.duration != null) ...[
                                    const Text(' • '),
                                    Text(build.durationString),
                                  ],
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (build.isCompleted)
                                    Chip(
                                      label: const Text('Success'),
                                      backgroundColor:
                                          Colors.green.withValues(alpha: 0.2),
                                      side: BorderSide.none,
                                    )
                                  else if (build.isFailed)
                                    Chip(
                                      label: const Text('Failed'),
                                      backgroundColor:
                                          Colors.red.withValues(alpha: 0.2),
                                      side: BorderSide.none,
                                    )
                                  else if (build.isCancelled)
                                    Chip(
                                      label: const Text('Cancelled'),
                                      backgroundColor:
                                          Colors.orange.withValues(alpha: 0.2),
                                      side: BorderSide.none,
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Symbols.delete),
                                    onPressed: () =>
                                        _deleteBuild(context, build),
                                  ),
                                ],
                              ),
                              children: [
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.3),
                                    borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Build Log',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(
                                                Symbols.content_copy),
                                            iconSize: 16,
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                            tooltip: 'Copy build log',
                                            onPressed: () =>
                                                _copyBuildLog(context, build),
                                          ),
                                          IconButton(
                                            icon:
                                                const Icon(Symbols.description),
                                            iconSize: 16,
                                            padding: const EdgeInsets.all(4),
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                            tooltip: 'Copy build details',
                                            onPressed: () => _copyBuildDetails(
                                                context, build),
                                          ),
                                          const Spacer(),
                                          if (build.errorMessage != null)
                                            Chip(
                                              label: const Text('Error'),
                                              backgroundColor: Colors.red
                                                  .withValues(alpha: 0.2),
                                              side: BorderSide.none,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: double.infinity,
                                        height: 200,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: SingleChildScrollView(
                                          child: Text(
                                            build.logs.join('\n'),
                                            style: const TextStyle(
                                              fontFamily: 'monospace',
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getBuildStatusColor(BuildStatus status, BuildContext context) {
    switch (status) {
      case BuildStatus.completed:
        return Colors.green;
      case BuildStatus.failed:
        return Colors.red;
      case BuildStatus.cancelled:
        return Colors.orange;
      case BuildStatus.running:
        return Theme.of(context).colorScheme.primary;
      default:
        return Colors.grey;
    }
  }

  IconData _getBuildStatusIcon(BuildStatus status) {
    switch (status) {
      case BuildStatus.completed:
        return Symbols.check;
      case BuildStatus.failed:
        return Symbols.close;
      case BuildStatus.cancelled:
        return Symbols.cancel;
      case BuildStatus.running:
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

  void _deleteBuild(BuildContext context, BuildProgress build) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Build'),
        content:
            const Text('Are you sure you want to delete this build record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<BuildProvider>().deleteBuild(build.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _copyBuildLog(BuildContext context, BuildProgress build) async {
    final logText = build.logs.join('\n');
    await Clipboard.setData(ClipboardData(text: logText));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Build log copied to clipboard (${build.logs.length} lines)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _copyBuildDetails(BuildContext context, BuildProgress build) async {
    final buffer = StringBuffer();
    buffer.writeln('=== Build Details ===');
    buffer.writeln('Status: ${build.status.name}');
    buffer.writeln('Current Step: ${build.currentStep}');
    buffer.writeln('Progress: ${(build.progress * 100).toStringAsFixed(1)}%');
    buffer.writeln('Start Time: ${build.startTime}');
    if (build.endTime != null) {
      buffer.writeln('End Time: ${build.endTime}');
      buffer.writeln('Duration: ${build.durationString}');
    }
    if (build.errorMessage != null) {
      buffer.writeln('Error: ${build.errorMessage}');
    }
    if (build.outputPath.isNotEmpty) {
      buffer.writeln('Output Path: ${build.outputPath}');
    }
    buffer.writeln();
    buffer.writeln('=== Build Log ===');
    buffer.writeln(build.logs.join('\n'));

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Complete build details copied to clipboard'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
