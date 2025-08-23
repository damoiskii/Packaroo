import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../providers/project_provider.dart';
import '../models/packaroo_project.dart';
import '../screens/project_edit_screen.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({super.key});

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search projects...',
                  prefixIcon: const Icon(Symbols.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Symbols.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              if (_searchQuery.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Symbols.info,
                        size: 16,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Drag projects to reorder them. Order is saved automatically.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        // Project list
        Expanded(
          child: Consumer<ProjectProvider>(
            builder: (context, projectProvider, child) {
              if (projectProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final projects = _searchQuery.isEmpty
                  ? projectProvider.projects
                  : projectProvider.searchProjects(_searchQuery);

              if (projects.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isEmpty
                            ? Symbols.folder_off
                            : Symbols.search_off,
                        size: 48,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isEmpty
                            ? 'No projects yet'
                            : 'No projects found',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isEmpty
                            ? 'Create your first project to get started'
                            : 'Try a different search term',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return _searchQuery.isEmpty
                  ? _buildReorderableList(context, projects, projectProvider)
                  : _buildSearchResults(context, projects, projectProvider);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReorderableList(BuildContext context,
      List<PackarooProject> projects, ProjectProvider projectProvider) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false, // Disable default drag handles
      itemCount: projects.length,
      onReorder: (oldIndex, newIndex) {
        projectProvider.reorderProjects(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, project, projectProvider,
            key: ValueKey(project.id));
      },
    );
  }

  Widget _buildSearchResults(BuildContext context,
      List<PackarooProject> projects, ProjectProvider projectProvider) {
    return ListView.builder(
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectCard(context, project, projectProvider);
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, PackarooProject project,
      ProjectProvider projectProvider,
      {Key? key}) {
    final isSelected = projectProvider.selectedProject?.id == project.id;

    return Card(
      key: key,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isSelected ? 4 : 1,
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_searchQuery.isEmpty)
              Icon(
                Symbols.drag_handle,
                size: 20,
                color: Theme.of(context).colorScheme.outline,
              ),
            if (_searchQuery.isEmpty) const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Symbols.package_2,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
        title: Text(
          project.displayName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (project.description.isNotEmpty)
              Text(
                project.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Symbols.schedule,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(project.lastModified),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Symbols.more_vert),
          onSelected: (value) => _handleMenuAction(context, value, project),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Symbols.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [
                  Icon(Symbols.content_copy),
                  SizedBox(width: 8),
                  Text('Duplicate'),
                ],
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              const PopupMenuItem(
                value: 'move_to_top',
                child: Row(
                  children: [
                    Icon(Symbols.keyboard_arrow_up),
                    SizedBox(width: 8),
                    Text('Move to Top'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'move_to_bottom',
                child: Row(
                  children: [
                    Icon(Symbols.keyboard_arrow_down),
                    SizedBox(width: 8),
                    Text('Move to Bottom'),
                  ],
                ),
              ),
            ],
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Symbols.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          projectProvider.selectProject(project);
        },
      ),
    );
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
      return 'Just now';
    }
  }

  void _handleMenuAction(
      BuildContext context, String action, PackarooProject project) {
    final projectProvider = context.read<ProjectProvider>();

    switch (action) {
      case 'edit':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ProjectEditScreen(project: project),
          ),
        );
        break;
      case 'duplicate':
        projectProvider.duplicateProject(project);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project duplicated successfully')),
        );
        break;
      case 'move_to_top':
        projectProvider.moveProjectToPosition(project.id, 0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project moved to top')),
        );
        break;
      case 'move_to_bottom':
        final lastIndex = projectProvider.projects.length - 1;
        projectProvider.moveProjectToPosition(project.id, lastIndex);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Project moved to bottom')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, project);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, PackarooProject project) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<ProjectProvider>().deleteProject(project.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Project deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
