import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _defaultJdkPathKey = 'default_jdk_path';
  static const String _defaultOutputPathKey = 'default_output_path';
  static const String _autoSaveKey = 'auto_save';
  static const String _showAdvancedOptionsKey = 'show_advanced_options';
  static const String _buildTimeoutKey = 'build_timeout';
  static const String _maxBuildHistoryKey = 'max_build_history';
  static const String _windowWidthKey = 'window_width';
  static const String _windowHeightKey = 'window_height';
  static const String _lastProjectPathKey = 'last_project_path';

  ThemeMode _themeMode = ThemeMode.system;
  String _defaultJdkPath = '';
  String _defaultOutputPath = '';
  bool _autoSave = true;
  bool _showAdvancedOptions = false;
  int _buildTimeout = 300; // 5 minutes in seconds
  int _maxBuildHistory = 100;
  double _windowWidth = 1200;
  double _windowHeight = 800;
  String _lastProjectPath = '';
  bool _isLoading = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get defaultJdkPath => _defaultJdkPath;
  String get defaultOutputPath => _defaultOutputPath;
  bool get autoSave => _autoSave;
  bool get showAdvancedOptions => _showAdvancedOptions;
  int get buildTimeout => _buildTimeout;
  int get maxBuildHistory => _maxBuildHistory;
  double get windowWidth => _windowWidth;
  double get windowHeight => _windowHeight;
  String get lastProjectPath => _lastProjectPath;
  bool get isLoading => _isLoading;

  /// Load settings from storage
  Future<void> loadSettings({bool notify = true}) async {
    _isLoading = true;
    if (notify) notifyListeners();

    try {
      final themeModeString = StorageService.getSetting<String>(_themeKey);
      if (themeModeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeModeString,
          orElse: () => ThemeMode.system,
        );
      }

      _defaultJdkPath =
          StorageService.getSetting<String>(_defaultJdkPathKey) ?? '';
      _defaultOutputPath =
          StorageService.getSetting<String>(_defaultOutputPathKey) ?? '';
      _autoSave = StorageService.getSetting<bool>(_autoSaveKey) ?? true;
      _showAdvancedOptions =
          StorageService.getSetting<bool>(_showAdvancedOptionsKey) ?? false;
      _buildTimeout = StorageService.getSetting<int>(_buildTimeoutKey) ?? 300;
      _maxBuildHistory =
          StorageService.getSetting<int>(_maxBuildHistoryKey) ?? 100;
      _windowWidth = StorageService.getSetting<double>(_windowWidthKey) ?? 1200;
      _windowHeight =
          StorageService.getSetting<double>(_windowHeightKey) ?? 800;
      _lastProjectPath =
          StorageService.getSetting<String>(_lastProjectPathKey) ?? '';
    } catch (e) {
      debugPrint('Error loading settings: $e');
    } finally {
      _isLoading = false;
      if (notify) notifyListeners();
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await StorageService.setSetting(_themeKey, mode.name);
    notifyListeners();
  }

  /// Set default JDK path
  Future<void> setDefaultJdkPath(String path) async {
    _defaultJdkPath = path;
    await StorageService.setSetting(_defaultJdkPathKey, path);
    notifyListeners();
  }

  /// Set default output path
  Future<void> setDefaultOutputPath(String path) async {
    _defaultOutputPath = path;
    await StorageService.setSetting(_defaultOutputPathKey, path);
    notifyListeners();
  }

  /// Set auto save
  Future<void> setAutoSave(bool enabled) async {
    _autoSave = enabled;
    await StorageService.setSetting(_autoSaveKey, enabled);
    notifyListeners();
  }

  /// Set show advanced options
  Future<void> setShowAdvancedOptions(bool show) async {
    _showAdvancedOptions = show;
    await StorageService.setSetting(_showAdvancedOptionsKey, show);
    notifyListeners();
  }

  /// Set build timeout
  Future<void> setBuildTimeout(int timeout) async {
    _buildTimeout = timeout;
    await StorageService.setSetting(_buildTimeoutKey, timeout);
    notifyListeners();
  }

  /// Set max build history
  Future<void> setMaxBuildHistory(int max) async {
    _maxBuildHistory = max;
    await StorageService.setSetting(_maxBuildHistoryKey, max);
    notifyListeners();
  }

  /// Set window size
  Future<void> setWindowSize(double width, double height) async {
    _windowWidth = width;
    _windowHeight = height;
    await StorageService.setSetting(_windowWidthKey, width);
    await StorageService.setSetting(_windowHeightKey, height);
    notifyListeners();
  }

  /// Set last project path
  Future<void> setLastProjectPath(String path) async {
    _lastProjectPath = path;
    await StorageService.setSetting(_lastProjectPathKey, path);
    notifyListeners();
  }

  /// Reset settings to default
  Future<void> resetToDefaults() async {
    _themeMode = ThemeMode.system;
    _defaultJdkPath = '';
    _defaultOutputPath = '';
    _autoSave = true;
    _showAdvancedOptions = false;
    _buildTimeout = 300;
    _maxBuildHistory = 100;
    _windowWidth = 1200;
    _windowHeight = 800;
    _lastProjectPath = '';

    await Future.wait([
      StorageService.setSetting(_themeKey, _themeMode.name),
      StorageService.setSetting(_defaultJdkPathKey, _defaultJdkPath),
      StorageService.setSetting(_defaultOutputPathKey, _defaultOutputPath),
      StorageService.setSetting(_autoSaveKey, _autoSave),
      StorageService.setSetting(_showAdvancedOptionsKey, _showAdvancedOptions),
      StorageService.setSetting(_buildTimeoutKey, _buildTimeout),
      StorageService.setSetting(_maxBuildHistoryKey, _maxBuildHistory),
      StorageService.setSetting(_windowWidthKey, _windowWidth),
      StorageService.setSetting(_windowHeightKey, _windowHeight),
      StorageService.setSetting(_lastProjectPathKey, _lastProjectPath),
    ]);

    notifyListeners();
  }

  /// Export settings
  Map<String, dynamic> exportSettings() {
    return {
      'themeMode': _themeMode.name,
      'defaultJdkPath': _defaultJdkPath,
      'defaultOutputPath': _defaultOutputPath,
      'autoSave': _autoSave,
      'showAdvancedOptions': _showAdvancedOptions,
      'buildTimeout': _buildTimeout,
      'maxBuildHistory': _maxBuildHistory,
      'windowWidth': _windowWidth,
      'windowHeight': _windowHeight,
      'lastProjectPath': _lastProjectPath,
    };
  }

  /// Import settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      if (settings['themeMode'] != null) {
        final mode = ThemeMode.values.firstWhere(
          (mode) => mode.name == settings['themeMode'],
          orElse: () => ThemeMode.system,
        );
        await setThemeMode(mode);
      }

      if (settings['defaultJdkPath'] != null) {
        await setDefaultJdkPath(settings['defaultJdkPath']);
      }

      if (settings['defaultOutputPath'] != null) {
        await setDefaultOutputPath(settings['defaultOutputPath']);
      }

      if (settings['autoSave'] != null) {
        await setAutoSave(settings['autoSave']);
      }

      if (settings['showAdvancedOptions'] != null) {
        await setShowAdvancedOptions(settings['showAdvancedOptions']);
      }

      if (settings['buildTimeout'] != null) {
        await setBuildTimeout(settings['buildTimeout']);
      }

      if (settings['maxBuildHistory'] != null) {
        await setMaxBuildHistory(settings['maxBuildHistory']);
      }

      if (settings['windowWidth'] != null && settings['windowHeight'] != null) {
        await setWindowSize(settings['windowWidth'], settings['windowHeight']);
      }

      if (settings['lastProjectPath'] != null) {
        await setLastProjectPath(settings['lastProjectPath']);
      }
    } catch (e) {
      debugPrint('Error importing settings: $e');
      rethrow;
    }
  }

  /// Get theme brightness
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.dark:
        return true;
      case ThemeMode.light:
        return false;
      case ThemeMode.system:
        return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;
    }
  }

  /// Toggle theme mode
  Future<void> toggleThemeMode() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }
}
