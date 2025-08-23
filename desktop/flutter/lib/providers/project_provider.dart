import 'package:flutter/foundation.dart';
import '../models/packaroo_project.dart';
import '../services/storage_service.dart';
import '../services/package_service.dart';

class ProjectProvider extends ChangeNotifier {
  final List<PackarooProject> _projects = [];
  final PackageService _packageService = PackageService();
  PackarooProject? _selectedProject;
  bool _isLoading = false;
  String? _error;

  List<PackarooProject> get projects => List.unmodifiable(_projects);
  PackarooProject? get selectedProject => _selectedProject;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProjects => _projects.isNotEmpty;

  /// Load all projects from storage
  Future<void> loadProjects() async {
    _setLoading(true);
    try {
      _projects.clear();
      _projects.addAll(StorageService.getAllProjects());
      _projects.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _error = null;
    } catch (e) {
      _error = 'Failed to load projects: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new project
  Future<void> createProject(PackarooProject project) async {
    try {
      // Set the sort order to be at the end of the list
      final maxOrder = _projects.isEmpty
          ? 0
          : _projects.map((p) => p.sortOrder).reduce((a, b) => a > b ? a : b);
      project.sortOrder = maxOrder + 1;

      await StorageService.saveProject(project);
      _projects.add(project);
      _projects.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _selectedProject = project;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create project: $e';
      notifyListeners();
    }
  }

  /// Update an existing project
  Future<void> updateProject(PackarooProject project) async {
    try {
      await StorageService.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
        if (_selectedProject?.id == project.id) {
          _selectedProject = project;
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update project: $e';
      notifyListeners();
    }
  }

  /// Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      await StorageService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
      if (_selectedProject?.id == projectId) {
        _selectedProject = null;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete project: $e';
      notifyListeners();
    }
  }

  /// Duplicate a project
  Future<void> duplicateProject(PackarooProject project) async {
    try {
      // Set the sort order to be after the original project
      final originalIndex = _projects.indexWhere((p) => p.id == project.id);
      final insertOrder =
          originalIndex >= 0 && originalIndex < _projects.length - 1
              ? (_projects[originalIndex].sortOrder +
                      _projects[originalIndex + 1].sortOrder) /
                  2
              : (_projects.isEmpty ? 1 : _projects.last.sortOrder + 1);

      final duplicate = project.copyWith(
        id: null, // Will generate new ID
        name: '${project.name} (Copy)',
        appName: '${project.appName}Copy',
        sortOrder: insertOrder.round(),
      );
      await createProject(duplicate);
    } catch (e) {
      _error = 'Failed to duplicate project: $e';
      notifyListeners();
    }
  }

  /// Select a project
  void selectProject(PackarooProject? project) {
    _selectedProject = project;
    notifyListeners();
  }

  /// Get project by ID
  PackarooProject? getProject(String id) {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Validate a project
  Future<bool> validateProject(PackarooProject project) async {
    try {
      final result = await _packageService.validateProject(project);
      return result.isValid;
    } catch (e) {
      _error = 'Validation failed: $e';
      notifyListeners();
      return false;
    }
  }

  /// Search projects
  List<PackarooProject> searchProjects(String query) {
    if (query.isEmpty) return projects;

    final lowercaseQuery = query.toLowerCase();
    return _projects.where((project) {
      return project.name.toLowerCase().contains(lowercaseQuery) ||
          project.description.toLowerCase().contains(lowercaseQuery) ||
          project.appName.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reorder projects by moving a project from oldIndex to newIndex
  Future<void> reorderProjects(int oldIndex, int newIndex) async {
    try {
      if (oldIndex == newIndex) return;

      // Adjust newIndex if moving down the list
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      // Get the project to move
      final project = _projects.removeAt(oldIndex);
      _projects.insert(newIndex, project);

      // Update sort orders for all projects to maintain order
      await _updateSortOrders();

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reorder projects: $e';
      notifyListeners();
    }
  }

  /// Move a project to a specific position
  Future<void> moveProjectToPosition(String projectId, int newPosition) async {
    try {
      final oldIndex = _projects.indexWhere((p) => p.id == projectId);
      if (oldIndex == -1) return;

      final clampedPosition = newPosition.clamp(0, _projects.length - 1);
      await reorderProjects(oldIndex, clampedPosition);
    } catch (e) {
      _error = 'Failed to move project: $e';
      notifyListeners();
    }
  }

  /// Update sort orders for all projects based on their current position in the list
  Future<void> _updateSortOrders() async {
    for (int i = 0; i < _projects.length; i++) {
      final project = _projects[i];
      final newOrder =
          i * 1000; // Use increments of 1000 to allow for future insertions
      if (project.sortOrder != newOrder) {
        final updatedProject = project.copyWith(sortOrder: newOrder);
        _projects[i] = updatedProject;
        await StorageService.updateProject(updatedProject);
      }
    }
  }

  /// Reset project order to creation date order
  Future<void> resetProjectOrder() async {
    try {
      _projects.sort((a, b) => a.createdDate.compareTo(b.createdDate));
      await _updateSortOrders();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to reset project order: $e';
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
