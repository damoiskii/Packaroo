import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/build_progress.dart';
import '../models/packaroo_project.dart';
import '../services/storage_service.dart';
import '../services/package_service.dart';

class BuildProvider extends ChangeNotifier {
  final PackageService _packageService = PackageService();
  final Map<String, BuildProgress> _activeBuilds = {};
  final List<BuildProgress> _buildHistory = [];
  bool _isLoading = false;
  String? _error;

  Map<String, BuildProgress> get activeBuilds =>
      Map.unmodifiable(_activeBuilds);
  List<BuildProgress> get buildHistory => List.unmodifiable(_buildHistory);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasActiveBuilds => _activeBuilds.isNotEmpty;

  /// Load build history from storage
  Future<void> loadBuildHistory() async {
    _setLoading(true);
    try {
      _buildHistory.clear();
      _buildHistory.addAll(StorageService.getAllBuilds());
      _buildHistory.sort((a, b) => b.startTime.compareTo(a.startTime));
      _error = null;
    } catch (e) {
      _error = 'Failed to load build history: $e';
    } finally {
      _setLoading(false);
    }
  }

  /// Start a new build
  Future<void> startBuild(PackarooProject project) async {
    print(
        'BuildProvider.startBuild: Starting build for project ${project.name} (id: ${project.id})');

    try {
      // Check if project is already building
      if (_activeBuilds.containsKey(project.id)) {
        _error = 'Project is already building';
        notifyListeners();
        print('BuildProvider.startBuild: Project already building, aborting');
        return;
      }

      _error = null;

      // Create initial build progress and add to active builds
      final initialProgress = BuildProgress(
        id: 'build_${project.id}_${DateTime.now().millisecondsSinceEpoch}',
        projectId: project.id,
        status: BuildStatus.running,
        progress: 0.0,
        currentStep: 'Initializing build...',
        startTime: DateTime.now(),
      );

      _activeBuilds[project.id] = initialProgress;
      print(
          'BuildProvider.startBuild: Added initial progress to active builds. Active builds count: ${_activeBuilds.length}');
      notifyListeners();

      // Start the build process
      print('BuildProvider.startBuild: Calling PackageService.buildPackage');
      final buildProgress = await _packageService.buildPackage(
        project,
        (progress) => _onBuildProgressUpdate(progress),
      );
      print(
          'BuildProvider.startBuild: PackageService.buildPackage completed with status: ${buildProgress.status}');

      // Save to history when complete
      await StorageService.saveBuildProgress(buildProgress);
      _buildHistory.insert(0, buildProgress);

      // Remove from active builds
      _activeBuilds.remove(project.id);
      print(
          'BuildProvider.startBuild: Removed from active builds. Active builds count: ${_activeBuilds.length}');

      notifyListeners();
    } catch (e) {
      _error = 'Failed to start build: $e';
      _activeBuilds.remove(project.id);
      print('BuildProvider.startBuild: ERROR - $e');
      notifyListeners();
    }
  }

  /// Cancel an active build
  Future<void> cancelBuild(String projectId) async {
    final build = _activeBuilds[projectId];
    if (build != null) {
      build.cancel();
      await StorageService.saveBuildProgress(build);
      _buildHistory.insert(0, build);
      _activeBuilds.remove(projectId);
      notifyListeners();
    }
  }

  /// Get builds for a specific project
  List<BuildProgress> getBuildsForProject(String projectId) {
    return StorageService.getBuildsForProject(projectId);
  }

  /// Get active build for project
  BuildProgress? getActiveBuild(String projectId) {
    return _activeBuilds[projectId];
  }

  /// Check if project is currently building
  bool isBuildingProject(String projectId) {
    return _activeBuilds.containsKey(projectId);
  }

  /// Delete build from history
  Future<void> deleteBuild(String buildId) async {
    try {
      await StorageService.deleteBuildProgress(buildId);
      _buildHistory.removeWhere((build) => build.id == buildId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete build: $e';
      notifyListeners();
    }
  }

  /// Clear build history
  Future<void> clearBuildHistory() async {
    try {
      for (final build in _buildHistory) {
        await StorageService.deleteBuildProgress(build.id);
      }
      _buildHistory.clear();
      notifyListeners();
    } catch (e) {
      _error = 'Failed to clear build history: $e';
      notifyListeners();
    }
  }

  /// Clean up old builds (keep only recent ones)
  Future<void> cleanupOldBuilds({int keepCount = 50}) async {
    try {
      await StorageService.clearOldBuilds(keepCount: keepCount);
      await loadBuildHistory();
    } catch (e) {
      _error = 'Failed to cleanup old builds: $e';
      notifyListeners();
    }
  }

  /// Get build statistics
  Map<String, dynamic> getBuildStatistics() {
    final completed = _buildHistory.where((b) => b.isCompleted).length;
    final failed = _buildHistory.where((b) => b.isFailed).length;
    final cancelled = _buildHistory.where((b) => b.isCancelled).length;
    final total = _buildHistory.length;

    double averageDuration = 0.0;
    final completedBuilds = _buildHistory.where((b) => b.isCompleted);
    if (completedBuilds.isNotEmpty) {
      final totalDuration = completedBuilds
          .map((b) => b.duration?.inSeconds ?? 0)
          .reduce((a, b) => a + b);
      averageDuration = totalDuration / completedBuilds.length;
    }

    return {
      'total': total,
      'completed': completed,
      'failed': failed,
      'cancelled': cancelled,
      'successRate':
          total > 0 ? (completed / total * 100).toStringAsFixed(1) : '0.0',
      'averageDuration': '${(averageDuration / 60).toStringAsFixed(1)}m',
    };
  }

  /// Search builds
  List<BuildProgress> searchBuilds(String query) {
    if (query.isEmpty) return buildHistory;

    final lowercaseQuery = query.toLowerCase();
    return _buildHistory.where((build) {
      return build.currentStep.toLowerCase().contains(lowercaseQuery) ||
          build.logs.any((log) => log.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Filter builds by status
  List<BuildProgress> filterBuildsByStatus(BuildStatus status) {
    return _buildHistory.where((build) => build.status == status).toList();
  }

  /// Get recent builds
  List<BuildProgress> getRecentBuilds({int limit = 10}) {
    return _buildHistory.take(limit).toList();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Internal method to handle build progress updates
  void _onBuildProgressUpdate(BuildProgress progress) {
    print(
        'BuildProvider._onBuildProgressUpdate: Project ${progress.projectId}, Status: ${progress.status}, Progress: ${progress.progress}, Step: ${progress.currentStep}');
    _activeBuilds[progress.projectId] = progress;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  @override
  void dispose() {
    // Cancel any active builds when provider is disposed
    for (final build in _activeBuilds.values) {
      build.cancel();
    }
    super.dispose();
  }
}
