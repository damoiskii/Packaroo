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
      _projects.sort((a, b) => b.lastModified.compareTo(a.lastModified));
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
      await StorageService.saveProject(project);
      _projects.insert(0, project);
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
      final duplicate = project.copyWith(
        id: null, // Will generate new ID
        name: '${project.name} (Copy)',
        appName: '${project.appName}Copy',
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
