import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/project_provider.dart';
import '../providers/build_provider.dart';
import '../widgets/project_list.dart';
import '../widgets/project_details.dart';
import '../widgets/build_monitor.dart';
import '../widgets/jar_analyzer_widget.dart';
import '../widgets/app_icon.dart';
import '../widgets/build_config_dialog.dart';
import 'project_edit_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Custom Navigation Rail with full-width highlighting
          Container(
            width: _isDrawerOpen ? 200 : 56,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                // Header section with menu toggle, app icon, and name
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Menu toggle button at extreme left
                      Container(
                        alignment: _isDrawerOpen
                            ? Alignment.centerLeft
                            : Alignment.center,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: _isDrawerOpen ? 'Close Menu' : 'Open Menu',
                          icon: Icon(
                              _isDrawerOpen ? Symbols.menu_open : Symbols.menu),
                          onPressed: () {
                            setState(() {
                              _isDrawerOpen = !_isDrawerOpen;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      // App icon and name at extreme left
                      if (_isDrawerOpen) ...[
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AppIcon(size: 32, showTooltip: true),
                              const SizedBox(width: 8),
                              Text(
                                'Packaroo',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ] else ...[
                        Container(
                          alignment: Alignment.center,
                          child: const AppIcon(size: 32, showTooltip: true),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),

                // Custom navigation items with full-width highlighting
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(0, Symbols.folder, 'Projects'),
                      _buildNavItem(1, Symbols.analytics, 'JAR Analyzer'),
                      _buildNavItem(2, Symbols.build, 'Builds'),
                      _buildNavItem(3, Symbols.settings, 'Settings'),
                    ],
                  ),
                ),

                // Trailing section with active builds indicator
                if (_isDrawerOpen)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Consumer<BuildProvider>(
                      builder: (context, buildProvider, child) {
                        if (buildProvider.hasActiveBuilds) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${buildProvider.activeBuilds.length} active',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
              ],
            ),
          ),

          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // App Bar
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Text(
                        _getScreenTitle(),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const Spacer(),
                      if (_selectedIndex == 0) ...[
                        // Project actions
                        Consumer<ProjectProvider>(
                          builder: (context, projectProvider, child) {
                            return Row(
                              children: [
                                if (projectProvider.selectedProject !=
                                    null) ...[
                                  IconButton(
                                    icon: const Icon(Symbols.edit),
                                    tooltip: 'Edit Project',
                                    onPressed: () => _editProject(context),
                                  ),
                                  IconButton(
                                    icon: const Icon(Symbols.content_copy),
                                    tooltip: 'Duplicate Project',
                                    onPressed: () => _duplicateProject(context),
                                  ),
                                  Consumer<BuildProvider>(
                                    builder: (context, buildProvider, child) {
                                      final isBuilding =
                                          buildProvider.isBuildingProject(
                                        projectProvider.selectedProject!.id,
                                      );

                                      return Row(
                                        children: [
                                          // Quick build button
                                          FilledButton.icon(
                                            icon: Icon(isBuilding
                                                ? Symbols.stop
                                                : Symbols.play_arrow),
                                            label: Text(isBuilding
                                                ? 'Stop'
                                                : 'Quick Build'),
                                            onPressed: isBuilding
                                                ? () => _stopBuild(context)
                                                : () => _quickBuild(context),
                                          ),
                                          const SizedBox(width: 8),
                                          // Configuration button
                                          OutlinedButton.icon(
                                            icon: const Icon(Symbols.tune),
                                            label:
                                                const Text('Configure & Build'),
                                            onPressed: isBuilding
                                                ? null
                                                : () =>
                                                    _configureBuild(context),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ],
                                const SizedBox(width: 8),
                                FilledButton.icon(
                                  icon: const Icon(Symbols.add),
                                  label: const Text('New Project'),
                                  onPressed: () => _createProject(context),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      const SizedBox(width: 16),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _buildContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Projects';
      case 1:
        return 'JAR Analyzer';
      case 2:
        return 'Build Monitor';
      case 3:
        return 'Settings';
      default:
        return 'Packaroo';
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildProjectsContent();
      case 1:
        return _buildJarAnalyzerContent();
      case 2:
        return const BuildMonitor();
      case 3:
        return const SettingsScreen();
      default:
        return _buildProjectsContent();
    }
  }

  Widget _buildProjectsContent() {
    return Row(
      children: [
        // Project List
        Expanded(
          flex: 1,
          child: Card(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Projects',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      Consumer<ProjectProvider>(
                        builder: (context, provider, child) {
                          return Text(
                            '${provider.projects.length} projects',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                const Expanded(child: ProjectList()),
              ],
            ),
          ),
        ),

        // Project Details
        Expanded(
          flex: 2,
          child: Card(
            margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
            child: Consumer<ProjectProvider>(
              builder: (context, projectProvider, child) {
                if (projectProvider.selectedProject == null) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.folder_open,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Select a project to view details',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const ProjectDetails();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildJarAnalyzerContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: const JarAnalyzerWidget(),
          ),
        ],
      ),
    );
  }

  void _createProject(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProjectEditScreen(),
      ),
    );
  }

  void _editProject(BuildContext context) {
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProjectEditScreen(project: project),
        ),
      );
    }
  }

  void _duplicateProject(BuildContext context) {
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      context.read<ProjectProvider>().duplicateProject(project);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Project duplicated successfully')),
      );
    }
  }

  void _quickBuild(BuildContext context) {
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      // Start build immediately with current project settings
      final buildProvider = context.read<BuildProvider>();
      buildProvider.startBuild(project);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quick build started for ${project.name}'),
          action: SnackBarAction(
            label: 'View Progress',
            onPressed: () {
              setState(() {
                _selectedIndex = 2; // Switch to Build Monitor tab
              });
            },
          ),
        ),
      );
    }
  }

  void _configureBuild(BuildContext context) {
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      _showBuildDialog(context, project);
    }
  }

  Future<void> _showBuildDialog(BuildContext context, dynamic project) async {
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => BuildConfigDialog(project: project),
    );

    if (result != null && mounted) {
      // Update the project with the new configuration
      final projectProvider = context.read<ProjectProvider>();
      await projectProvider.updateProject(result);

      // Start build with the configured project
      final buildProvider = context.read<BuildProvider>();
      await buildProvider.startBuild(result);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Build started for ${result.name}'),
            action: SnackBarAction(
              label: 'View Progress',
              onPressed: () {
                setState(() {
                  _selectedIndex = 2; // Switch to Build Monitor tab
                });
              },
            ),
          ),
        );
      }
    }
  }

  void _stopBuild(BuildContext context) {
    final project = context.read<ProjectProvider>().selectedProject;
    if (project != null) {
      context.read<BuildProvider>().cancelBuild(project.id);
    }
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
          },
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                if (_isDrawerOpen) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
