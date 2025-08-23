import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/packaroo_project.dart';
import '../models/build_progress.dart';

class StorageService {
  static const String _projectsBoxName = 'projects';
  static const String _buildsBoxName = 'builds';
  static const String _settingsBoxName = 'settings';

  static Box<PackarooProject>? _projectsBox;
  static Box<BuildProgress>? _buildsBox;
  static Box<dynamic>? _settingsBox;

  /// Initialize the storage service
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PackarooProjectAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(BuildStatusAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BuildProgressAdapter());
    }

    // Open boxes
    _projectsBox = await Hive.openBox<PackarooProject>(_projectsBoxName);
    _buildsBox = await Hive.openBox<BuildProgress>(_buildsBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);

    // Migrate existing projects to add sortOrder if needed
    await _migrateProjectsSortOrder();
  }

  /// Migrate existing projects to ensure they have sortOrder values
  static Future<void> _migrateProjectsSortOrder() async {
    final projects = getAllProjects();
    bool needsMigration = false;

    for (int i = 0; i < projects.length; i++) {
      final project = projects[i];
      // Check if sortOrder is 0 or not set (default value)
      if (project.sortOrder == 0) {
        needsMigration = true;
        // Set sortOrder based on creation date order
        project.sortOrder = project.createdDate.millisecondsSinceEpoch;
        await _projectsBox?.put(project.id, project);
      }
    }

    if (needsMigration) {
      print('Migrated ${projects.length} projects to include sortOrder field');
    }
  }

  /// Close all boxes
  static Future<void> close() async {
    await _projectsBox?.close();
    await _buildsBox?.close();
    await _settingsBox?.close();
  }

  /// Projects CRUD operations
  static Future<void> saveProject(PackarooProject project) async {
    await _projectsBox?.put(project.id, project);
  }

  static PackarooProject? getProject(String id) {
    return _projectsBox?.get(id);
  }

  static List<PackarooProject> getAllProjects() {
    return _projectsBox?.values.toList() ?? [];
  }

  static PackarooProject? getProjectByName(String name) {
    final projects = getAllProjects();
    try {
      return projects.firstWhere(
          (project) => project.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearAllProjects() async {
    await _projectsBox?.clear();
    // Also clear related build progress
    await _buildsBox?.clear();
  }

  static Future<void> deleteProject(String id) async {
    await _projectsBox?.delete(id);
    // Also delete related build progress
    final builds = getAllBuilds().where((build) => build.projectId == id);
    for (final build in builds) {
      await deleteBuildProgress(build.id);
    }
  }

  static Future<void> updateProject(PackarooProject project) async {
    project.lastModified = DateTime.now();
    await saveProject(project);
  }

  /// Build Progress CRUD operations
  static Future<void> saveBuildProgress(BuildProgress progress) async {
    await _buildsBox?.put(progress.id, progress);
  }

  static BuildProgress? getBuildProgress(String id) {
    return _buildsBox?.get(id);
  }

  static List<BuildProgress> getAllBuilds() {
    return _buildsBox?.values.toList() ?? [];
  }

  static List<BuildProgress> getBuildsForProject(String projectId) {
    return getAllBuilds()
        .where((build) => build.projectId == projectId)
        .toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  static Future<void> deleteBuildProgress(String id) async {
    await _buildsBox?.delete(id);
  }

  static Future<void> clearOldBuilds({int keepCount = 50}) async {
    final builds = getAllBuilds()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    if (builds.length > keepCount) {
      final toDelete = builds.skip(keepCount);
      for (final build in toDelete) {
        await deleteBuildProgress(build.id);
      }
    }
  }

  /// Settings operations
  static Future<void> setSetting(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  static T? getSetting<T>(String key, [T? defaultValue]) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T?;
  }

  static Future<void> deleteSetting(String key) async {
    await _settingsBox?.delete(key);
  }

  static Map<String, dynamic> getAllSettings() {
    final box = _settingsBox;
    if (box == null) return {};

    final settings = <String, dynamic>{};
    for (final key in box.keys) {
      settings[key.toString()] = box.get(key);
    }
    return settings;
  }

  /// Export/Import functionality
  static Map<String, dynamic> exportData() {
    final projects = getAllProjects().map((p) => p.toJson()).toList();
    final builds = getAllBuilds().map((b) => b.toJson()).toList();
    final settings = getAllSettings();

    return {
      'projects': projects,
      'builds': builds,
      'settings': settings,
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }

  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Clear existing data
      await _projectsBox?.clear();
      await _buildsBox?.clear();
      await _settingsBox?.clear();

      // Import projects
      if (data['projects'] != null) {
        final projects = (data['projects'] as List)
            .map((json) => PackarooProject.fromJson(json))
            .toList();

        for (final project in projects) {
          await saveProject(project);
        }
      }

      // Import builds
      if (data['builds'] != null) {
        final builds = (data['builds'] as List)
            .map((json) => BuildProgress.fromJson(json))
            .toList();

        for (final build in builds) {
          await saveBuildProgress(build);
        }
      }

      // Import settings
      if (data['settings'] != null) {
        final settings = data['settings'] as Map<String, dynamic>;
        for (final entry in settings.entries) {
          await setSetting(entry.key, entry.value);
        }
      }
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Backup functionality
  static Future<void> createBackup() async {
    final data = exportData();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await setSetting('backup_$timestamp', data);

    // Keep only the last 5 backups
    final allSettings = getAllSettings();
    final backupKeys = allSettings.keys
        .where((key) => key.startsWith('backup_'))
        .toList()
      ..sort();

    if (backupKeys.length > 5) {
      final toDelete = backupKeys.take(backupKeys.length - 5);
      for (final key in toDelete) {
        await deleteSetting(key);
      }
    }
  }

  static List<DateTime> getAvailableBackups() {
    final allSettings = getAllSettings();
    return allSettings.keys
        .where((key) => key.startsWith('backup_'))
        .map((key) {
          final timestamp = int.tryParse(key.substring(7));
          return timestamp != null
              ? DateTime.fromMillisecondsSinceEpoch(timestamp)
              : null;
        })
        .where((date) => date != null)
        .cast<DateTime>()
        .toList()
      ..sort((a, b) => b.compareTo(a));
  }

  static Future<void> restoreBackup(DateTime backupDate) async {
    final timestamp = backupDate.millisecondsSinceEpoch;
    final backupData = getSetting('backup_$timestamp');

    if (backupData != null) {
      await importData(backupData as Map<String, dynamic>);
    } else {
      throw Exception('Backup not found');
    }
  }
}

/// SharedPreferences wrapper for simple settings
class PreferencesService {
  static SharedPreferences? _prefs;

  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static String? getString(String key, [String? defaultValue]) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  static bool getBool(String key, [bool defaultValue = false]) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int getInt(String key, [int defaultValue = 0]) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs?.setDouble(key, value);
  }

  static double getDouble(String key, [double defaultValue = 0.0]) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs?.setStringList(key, value);
  }

  static List<String> getStringList(String key, [List<String>? defaultValue]) {
    return _prefs?.getStringList(key) ?? defaultValue ?? [];
  }

  static Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  static Future<void> clear() async {
    await _prefs?.clear();
  }

  static Set<String> getKeys() {
    return _prefs?.getKeys() ?? {};
  }
}
