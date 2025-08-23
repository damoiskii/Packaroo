import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class WindowIconManager {
  static Future<void> setApplicationIcon() async {
    try {
      if (Platform.isLinux) {
        await _setLinuxIcon();
      } else if (Platform.isWindows) {
        await _setWindowsIcon();
      } else if (Platform.isMacOS) {
        await _setMacOSIcon();
      }
    } catch (e) {
      print('Failed to set application icon: $e');
    }
  }

  static Future<void> _setLinuxIcon() async {
    try {
      // Load icon as bytes for better control
      final ByteData iconData = await rootBundle.load('assets/icons/icon.png');
      final Uint8List iconBytes = iconData.buffer.asUint8List();

      // Try multiple approaches for Linux
      bool iconSet = false;

      // Approach 1: Try with icon bytes
      try {
        // Note: This may not work with older window_manager versions
        // but worth trying
        await windowManager.setIcon('assets/icons/icon.png');
        print('Linux icon set via assets');
        iconSet = true;
      } catch (e1) {
        print('Asset path approach failed: $e1');
      }

      // Approach 2: Try absolute path
      if (!iconSet) {
        try {
          final currentDir = Directory.current.path;
          final possiblePaths = [
            '$currentDir/data/flutter_assets/assets/icons/icon.png',
            '$currentDir/assets/icons/icon.png',
            '${Platform.resolvedExecutable}/data/flutter_assets/assets/icons/icon.png',
          ];

          for (final iconPath in possiblePaths) {
            if (await File(iconPath).exists()) {
              await windowManager.setIcon(iconPath);
              print('Linux icon set via absolute path: $iconPath');
              iconSet = true;
              break;
            }
          }
        } catch (e2) {
          print('Absolute path approach failed: $e2');
        }
      }

      // Approach 3: Create temporary icon file
      if (!iconSet) {
        try {
          final tempDir = Directory.systemTemp;
          final tempIconFile = File('${tempDir.path}/packaroo_icon.png');
          await tempIconFile.writeAsBytes(iconBytes);
          await windowManager.setIcon(tempIconFile.path);
          print('Linux icon set via temporary file');
          iconSet = true;
        } catch (e3) {
          print('Temporary file approach failed: $e3');
        }
      }

      // Approach 4: Try setting window class for better desktop integration
      if (!iconSet) {
        try {
          // This helps window managers identify the application
          await _setWindowClass();
          await windowManager.setIcon('packaroo'); // Use app name as icon name
          print('Linux icon set via window class');
        } catch (e4) {
          print('Window class approach failed: $e4');
        }
      }
    } catch (e) {
      print('All Linux icon approaches failed: $e');
    }
  }

  static Future<void> _setWindowClass() async {
    try {
      // Set WM_CLASS for Linux window managers
      // This helps the desktop environment identify the application
      if (Platform.isLinux) {
        await Process.run('xprop', [
          '-id',
          await _getWindowId(),
          '-set',
          'WM_CLASS',
          '"packaroo", "Packaroo"'
        ]);
      }
    } catch (e) {
      print('Failed to set window class: $e');
    }
  }

  static Future<String> _getWindowId() async {
    try {
      final result = await Process.run('xdotool', ['getactivewindow']);
      return result.stdout.toString().trim();
    } catch (e) {
      print('Failed to get window ID: $e');
      return '';
    }
  }

  static Future<void> _setWindowsIcon() async {
    try {
      // For Windows, try the generated ICO file first
      await windowManager.setIcon('windows/runner/resources/app_icon.ico');
      print('Windows icon set via ICO file');
    } catch (e1) {
      try {
        // Fallback to PNG
        await windowManager.setIcon('assets/icons/icon.png');
        print('Windows icon set via PNG fallback');
      } catch (e2) {
        print('Windows icon setting failed: $e1, $e2');
      }
    }
  }

  static Future<void> _setMacOSIcon() async {
    try {
      // For macOS, the icon is usually handled by the bundle
      // But we can still try to set it programmatically
      await windowManager.setIcon('assets/icons/icon.png');
      print('macOS icon set');
    } catch (e) {
      print('macOS icon setting failed: $e');
    }
  }

  static Future<void> configureWindow() async {
    try {
      await windowManager.ensureInitialized();

      // Try to set icon before window creation
      if (Platform.isLinux) {
        try {
          await setApplicationIcon();
          print('Icon set before window creation');
        } catch (e) {
          print('Failed to set icon before window creation: $e');
        }
      }

      const windowOptions = WindowOptions(
        size: Size(1200, 700),
        center: true,
        backgroundColor: Color(0xFF202020),
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
        title: 'Packaroo - Java Application Packager',
        minimumSize: Size(800, 600),
        maximumSize: Size(1920, 1080),
        // Additional Linux-specific options that might help
        alwaysOnTop: false,
        fullScreen: false,
      );

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();

        // Set icon immediately after window is shown
        await setApplicationIcon();

        // Wait a bit and try again for Linux
        if (Platform.isLinux) {
          await Future.delayed(const Duration(milliseconds: 500));
          await setApplicationIcon();
          print('Icon set after delay');

          // Try setting additional window properties
          await _setLinuxWindowProperties();
        }
      });
    } catch (e) {
      print('Window configuration failed: $e');
    }
  }

  static Future<void> _setLinuxWindowProperties() async {
    if (!Platform.isLinux) return;

    try {
      // Set additional properties that help with icon display
      await windowManager.setTitle('Packaroo - Java Application Packager');

      // Try to set window class after window is created
      await Future.delayed(const Duration(milliseconds: 100));
      await _setWindowClass();
    } catch (e) {
      print('Failed to set Linux window properties: $e');
    }
  }
}
