import 'dart:io';
import 'package:path/path.dart' as path;

/// Service for analyzing JAR files to extract metadata and dependencies
class JarAnalyzerService {
  /// Analyzes a JAR file and extracts metadata
  Future<JarAnalysisResult> analyzeJar(String jarPath) async {
    try {
      final jarFile = File(jarPath);
      if (!await jarFile.exists()) {
        throw Exception('JAR file not found: $jarPath');
      }

      // Extract JAR contents to temporary directory for analysis
      final tempDir = await Directory.systemTemp.createTemp('packaroo_jar_');

      try {
        // Extract JAR file
        final extractResult = await Process.run(
          'jar',
          ['-xf', jarPath],
          workingDirectory: tempDir.path,
        );

        if (extractResult.exitCode != 0) {
          throw Exception('Failed to extract JAR: ${extractResult.stderr}');
        }

        // Analyze manifest
        final manifest = await _analyzeManifest(tempDir.path);

        // Find main class
        final mainClass = await _findMainClass(tempDir.path, manifest);

        // Analyze dependencies
        final dependencies = await _analyzeDependencies(jarPath);

        // Get JAR info
        final jarInfo = await _getJarInfo(jarPath);

        // Detect required modules
        final modules = await _detectRequiredModules(tempDir.path);

        return JarAnalysisResult(
          jarPath: jarPath,
          fileName: path.basename(jarPath),
          fileSize: await jarFile.length(),
          mainClass: mainClass,
          manifest: manifest,
          dependencies: dependencies,
          modules: modules,
          jarInfo: jarInfo,
        );
      } finally {
        // Clean up temp directory
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      throw Exception('JAR analysis failed: $e');
    }
  }

  /// Analyzes the MANIFEST.MF file
  Future<Map<String, String>> _analyzeManifest(String extractedPath) async {
    final manifestFile =
        File(path.join(extractedPath, 'META-INF', 'MANIFEST.MF'));
    final manifest = <String, String>{};

    if (await manifestFile.exists()) {
      final lines = await manifestFile.readAsLines();
      String? currentKey;

      for (final line in lines) {
        if (line.trim().isEmpty) continue;

        if (line.startsWith(' ') && currentKey != null) {
          // Continuation line
          manifest[currentKey] =
              (manifest[currentKey] ?? '') + line.substring(1);
        } else {
          final colonIndex = line.indexOf(':');
          if (colonIndex > 0) {
            currentKey = line.substring(0, colonIndex).trim();
            final value = line.substring(colonIndex + 1).trim();
            manifest[currentKey] = value;
          }
        }
      }
    }

    return manifest;
  }

  /// Finds the main class from manifest or by scanning
  Future<String> _findMainClass(
      String extractedPath, Map<String, String> manifest) async {
    // Extract both Main-Class and Start-Class from manifest
    final manifestMainClass = manifest['Main-Class'];
    final manifestStartClass = manifest['Start-Class'];

    // For Spring Boot applications, we need to determine the correct main class
    if (manifestMainClass != null && manifestMainClass.isNotEmpty) {
      // Check if this is a Spring Boot application
      final isSpringBoot =
          manifestMainClass.contains('org.springframework.boot.loader');

      if (isSpringBoot) {
        // For ALL Spring Boot applications, we MUST use the Spring Boot launcher (Main-Class)
        // This ensures proper classpath setup, regardless of whether it's JavaFX or not
        final isJavaFXApp = await _isJavaFXApplication(extractedPath);

        print('Detected Spring Boot application');
        print('Using Spring Boot launcher as main class: $manifestMainClass');
        if (manifestStartClass != null && manifestStartClass.isNotEmpty) {
          print('Actual application class (Start-Class): $manifestStartClass');
        }
        if (isJavaFXApp) {
          print('This Spring Boot application also uses JavaFX');
        }

        // Always return the Spring Boot launcher for proper classpath handling
        return manifestMainClass;
      } else {
        // For non-Spring Boot apps, use Main-Class directly
        print(
            'Using Main-Class for non-Spring Boot application: $manifestMainClass');
        return manifestMainClass;
      }
    }

    // If no Main-Class in manifest, scan for classes with main method
    final mainClasses = await _scanForMainClasses(extractedPath);

    if (mainClasses.isNotEmpty) {
      print('Found main class by scanning: ${mainClasses.first}');
      return mainClasses.first;
    }

    throw Exception('No main class found in JAR file');
  }

  /// Scans for classes containing main method
  Future<List<String>> _scanForMainClasses(String extractedPath) async {
    final mainClasses = <String>[];

    try {
      // Use javap to analyze class files
      final classFiles = await _findClassFiles(Directory(extractedPath));

      for (final classFile in classFiles) {
        try {
          final result = await Process.run(
            'javap',
            ['-public', classFile],
            workingDirectory: extractedPath,
          );

          if (result.exitCode == 0) {
            final output = result.stdout as String;
            if (output
                    .contains('public static void main(java.lang.String[])') ||
                output.contains('public static void main(String[])')) {
              // Convert file path to class name
              final className = classFile
                  .replaceAll('/', '.')
                  .replaceAll('\\', '.')
                  .replaceFirst(RegExp(r'\.class$'), '');
              mainClasses.add(className);
            }
          }
        } catch (e) {
          // Continue scanning other classes
          continue;
        }
      }
    } catch (e) {
      // If javap fails, return empty list
    }

    return mainClasses;
  }

  /// Finds all .class files in directory
  Future<List<String>> _findClassFiles(Directory dir) async {
    final classFiles = <String>[];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.class')) {
        final relativePath = path.relative(entity.path, from: dir.path);
        classFiles.add(relativePath);
      }
    }

    return classFiles;
  }

  /// Analyzes JAR dependencies
  Future<List<String>> _analyzeDependencies(String jarPath) async {
    final dependencies = <String>[];

    try {
      // Use jdeps to analyze dependencies
      final result = await Process.run('jdeps', ['-verbose:class', jarPath]);

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');

        for (final line in lines) {
          if (line.contains('->') && !line.contains('not found')) {
            final parts = line.split('->');
            if (parts.length >= 2) {
              final dependency = parts[1].trim();
              if (dependency.isNotEmpty && !dependencies.contains(dependency)) {
                dependencies.add(dependency);
              }
            }
          }
        }
      }
    } catch (e) {
      // jdeps might not be available, continue without dependencies
    }

    return dependencies;
  }

  /// Gets basic JAR file information
  Future<Map<String, dynamic>> _getJarInfo(String jarPath) async {
    final info = <String, dynamic>{};

    try {
      // Get JAR table of contents
      final result = await Process.run('jar', ['-tf', jarPath]);

      if (result.exitCode == 0) {
        final entries = (result.stdout as String)
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .toList();

        info['entryCount'] = entries.length;
        info['hasMetaInf'] =
            entries.any((entry) => entry.startsWith('META-INF/'));
        info['hasNativeLibs'] = entries.any((entry) =>
            entry.endsWith('.so') ||
            entry.endsWith('.dll') ||
            entry.endsWith('.dylib'));
        info['packageStructure'] = _analyzePackageStructure(entries);
      }
    } catch (e) {
      info['error'] = e.toString();
    }

    return info;
  }

  /// Analyzes package structure from JAR entries
  Map<String, int> _analyzePackageStructure(List<String> entries) {
    final packages = <String, int>{};

    for (final entry in entries) {
      if (entry.endsWith('.class')) {
        final packagePath = path.dirname(entry);
        if (packagePath != '.' && packagePath.isNotEmpty) {
          final packageName = packagePath.replaceAll('/', '.');
          packages[packageName] = (packages[packageName] ?? 0) + 1;
        }
      }
    }

    return packages;
  }

  /// Detects required Java modules
  Future<List<String>> _detectRequiredModules(String extractedPath) async {
    final modules = <String>{};

    try {
      // Check if it's a modular JAR
      final moduleInfoFile =
          File(path.join(extractedPath, 'module-info.class'));
      if (await moduleInfoFile.exists()) {
        // Parse module-info.class for dependencies
        final result = await Process.run(
            'javap', [path.join(extractedPath, 'module-info.class')]);

        if (result.exitCode == 0) {
          final output = result.stdout as String;
          final lines = output.split('\n');

          for (final line in lines) {
            if (line.trim().startsWith('requires ')) {
              final moduleName = line
                  .trim()
                  .replaceFirst('requires ', '')
                  .replaceAll(';', '')
                  .trim();
              if (moduleName.isNotEmpty &&
                  await _isModuleAvailable(moduleName)) {
                modules.add(moduleName);
              }
            }
          }
        }
      } else {
        // For non-modular JARs, detect application type and suggest appropriate modules
        final isJavaFXApp = await _isJavaFXApplication(extractedPath);
        final isSpringBootApp = await _hasSpringBootStructure(extractedPath);

        if (isJavaFXApp) {
          // Add JavaFX modules for JavaFX applications
          final defaultJavaFXModules = await _getDefaultJavaFXModules();
          modules.addAll(defaultJavaFXModules);

          // Add essential JavaFX modules
          await _addEssentialJavaFXModules(modules);

          print('JavaFX application detected, added essential JavaFX modules');

          // Additional modules often needed for JavaFX
          final additionalJavaFXModules = [
            'javafx.media', // Often needed for multimedia
            'javafx.web', // For WebView components
          ];

          for (final module in additionalJavaFXModules) {
            if (await _isModuleAvailable(module)) {
              modules.add(module);
            }
          }
        } else if (isSpringBootApp) {
          // For Spring Boot applications, add minimal modules
          // Similar to Java version - Spring Boot handles its own classpath
          final springBootModules = [
            'java.base',
            'java.desktop',
            'java.logging',
            'java.management',
            'java.naming',
            'java.sql',
            'java.xml',
          ];

          for (final module in springBootModules) {
            if (await _isModuleAvailable(module)) {
              modules.add(module);
            }
          }

          print('Spring Boot application detected, added minimal module set');
        } else {
          // For non-JavaFX applications, suggest common modules
          final commonModules = [
            'java.base',
            'java.desktop',
            'java.logging',
            'java.management',
            'java.naming',
            'java.sql',
            'java.xml',
          ];

          for (final module in commonModules) {
            if (await _isModuleAvailable(module)) {
              modules.add(module);
            }
          }
        }

        // Additional logging for Spring Boot with JavaFX applications
        if (isSpringBootApp && isJavaFXApp) {
          print(
              'Spring Boot with JavaFX application detected - will use appropriate main class configuration');
        }
      }
    } catch (e) {
      // If module detection fails, provide basic modules
      print('Module detection failed: $e, using basic modules');
      final basicModules = ['java.base', 'java.desktop'];
      for (final module in basicModules) {
        if (await _isModuleAvailable(module)) {
          modules.add(module);
        }
      }
    }

    return modules.toList();
  }

  /// Detects if the application uses JavaFX
  Future<bool> _isJavaFXApplication(String extractedPath) async {
    try {
      // Method 1: Check for JavaFX classes in the JAR
      final result =
          await Process.run('find', [extractedPath, '-name', '*.class']);

      if (result.exitCode == 0) {
        final classFiles = result.stdout as String;
        if (classFiles.contains('javafx') || classFiles.contains('JavaFX')) {
          return true;
        }
      }

      // Method 2: Check JAR contents using jar command for more thorough search
      final jarPath = Directory(extractedPath).parent.path;
      final jarFiles = Directory(jarPath)
          .listSync()
          .where((file) => file.path.endsWith('.jar'))
          .map((file) => file.path);

      for (final jarFile in jarFiles) {
        final jarResult = await Process.run('jar', ['-tf', jarFile]);
        if (jarResult.exitCode == 0) {
          final contents = jarResult.stdout as String;
          if (contents.contains('javafx') || contents.contains('JavaFX')) {
            return true;
          }
        }
      }

      // Method 3: Check manifest for JavaFX dependencies
      final manifestFile =
          File(path.join(extractedPath, 'META-INF', 'MANIFEST.MF'));
      if (await manifestFile.exists()) {
        final manifestContent = await manifestFile.readAsString();
        if (manifestContent.contains('javafx') ||
            manifestContent.contains('JavaFX')) {
          return true;
        }
      }

      // Method 4: Check for Spring Boot with potential JavaFX usage
      final hasSpringBoot = await _hasSpringBootStructure(extractedPath);
      if (hasSpringBoot) {
        // For Spring Boot apps, check more thoroughly for JavaFX usage
        final bootInfClasses =
            Directory(path.join(extractedPath, 'BOOT-INF', 'classes'));
        if (await bootInfClasses.exists()) {
          final findResult = await Process.run(
              'find', [bootInfClasses.path, '-name', '*.class']);
          if (findResult.exitCode == 0) {
            final classFiles = findResult.stdout as String;
            // Check if any class files are in JavaFX-related packages or contain JavaFX references
            if (classFiles.toLowerCase().contains('application') ||
                classFiles.toLowerCase().contains('desktop') ||
                classFiles.toLowerCase().contains('fx')) {
              // Additional check: look for JavaFX dependencies in BOOT-INF/lib
              final libDir =
                  Directory(path.join(extractedPath, 'BOOT-INF', 'lib'));
              if (await libDir.exists()) {
                final libFiles =
                    await libDir.list().map((file) => file.path).toList();
                if (libFiles.any((file) => file.contains('javafx'))) {
                  return true;
                }
              }
            }
          }
        }
      }

      return false;
    } catch (e) {
      // If detection fails, assume non-JavaFX
      return false;
    }
  }

  /// Detects if the application is a Spring Boot application with JavaFX
  /// This is a critical detection method for proper main class configuration
  Future<bool> isSpringBootWithJavaFXApplication(String jarPath) async {
    try {
      // Extract JAR to analyze its contents
      final tempDir =
          await Directory.systemTemp.createTemp('packaroo_analysis_');

      try {
        // Extract JAR file
        final extractResult = await Process.run(
          'jar',
          ['-xf', jarPath],
          workingDirectory: tempDir.path,
        );

        if (extractResult.exitCode != 0) {
          return false;
        }

        // Check if it's Spring Boot and JavaFX
        final hasSpringBoot = await _hasSpringBootStructure(tempDir.path);
        final hasJavaFX = await _isJavaFXApplication(tempDir.path);

        print(
            'Spring Boot detection: $hasSpringBoot, JavaFX detection: $hasJavaFX');

        return hasSpringBoot && hasJavaFX;
      } finally {
        // Clean up temp directory
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error detecting Spring Boot with JavaFX: $e');
      return false;
    }
  }

  /// Public method to detect if a JAR is a JavaFX application
  /// This method provides external access to JavaFX detection
  Future<bool> isJavaFXProject(String jarPath) async {
    try {
      // Extract JAR to analyze its contents
      final tempDir =
          await Directory.systemTemp.createTemp('packaroo_javafx_check_');

      try {
        // Extract JAR file
        final extractResult = await Process.run(
          'jar',
          ['-xf', jarPath],
          workingDirectory: tempDir.path,
        );

        if (extractResult.exitCode != 0) {
          return false;
        }

        return await _isJavaFXApplication(tempDir.path);
      } finally {
        // Clean up temp directory
        await tempDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error detecting JavaFX project: $e');
      return false;
    }
  }

  /// Gets available Java modules in the current runtime
  Future<Set<String>> _getAvailableModules() async {
    final modules = <String>{};

    try {
      final result = await Process.run('java', ['--list-modules']);

      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isNotEmpty && trimmed.contains('@')) {
            // Extract module name (before @)
            final moduleName = trimmed.split('@')[0];
            modules.add(moduleName);
          }
        }
      }
    } catch (e) {
      print('Could not get available modules: $e');
    }

    return modules;
  }

  /// Checks if a specific module is available in the current runtime
  Future<bool> _isModuleAvailable(String moduleName) async {
    try {
      final availableModules = await _getAvailableModules();
      final available = availableModules.contains(moduleName);

      // Special handling for known problematic modules
      if (!available && _isProblematicModule(moduleName)) {
        print(
            'Module $moduleName is not available in current runtime, skipping');
        return false;
      }

      return available;
    } catch (e) {
      print('Could not check availability of module: $moduleName - $e');
      return false;
    }
  }

  /// Identifies modules that are often problematic or not available in all distributions
  bool _isProblematicModule(String moduleName) {
    return moduleName == 'jdk.management.jfr' ||
        moduleName == 'jdk.jfr' ||
        moduleName == 'jdk.management.agent' ||
        moduleName.startsWith('jdk.internal.') ||
        moduleName.contains('incubator');
  }

  /// Gets default JavaFX modules with availability checking
  Future<Set<String>> _getDefaultJavaFXModules() async {
    final modules = <String>{};
    final defaultModules = [
      'java.base',
      'java.desktop',
      'java.logging',
      'java.management',
      'java.naming',
      'java.prefs',
      'java.xml',
      'javafx.controls',
      'javafx.fxml',
      'javafx.base',
      'javafx.graphics'
    ];

    for (final module in defaultModules) {
      if (await _isModuleAvailable(module)) {
        modules.add(module);
        print('Added default module: $module');
      }
    }

    return modules;
  }

  /// Adds essential JavaFX modules to the module set
  Future<void> _addEssentialJavaFXModules(Set<String> modules) async {
    final essentialJavaFXModules = [
      'javafx.controls',
      'javafx.fxml',
      'javafx.base',
      'javafx.graphics'
    ];

    for (final module in essentialJavaFXModules) {
      if (await _isModuleAvailable(module)) {
        modules.add(module);
        print('Added essential JavaFX module: $module');
      }
    }
  }

  /// Checks if the JAR has Spring Boot structure
  Future<bool> _hasSpringBootStructure(String extractedPath) async {
    final bootInfDir = Directory(path.join(extractedPath, 'BOOT-INF'));
    final metaInfDir = Directory(path.join(extractedPath, 'META-INF'));

    return await bootInfDir.exists() && await metaInfDir.exists();
  }

  /// Validates Java environment
  Future<JavaEnvironmentInfo> validateJavaEnvironment(String jdkPath) async {
    try {
      String javaCmd = 'java';
      String javacCmd = 'javac';
      String jpackageCmd = 'jpackage';
      String jlinkCmd = 'jlink';

      if (jdkPath.isNotEmpty) {
        final binPath = path.join(jdkPath, 'bin');
        javaCmd = path.join(binPath, Platform.isWindows ? 'java.exe' : 'java');
        javacCmd =
            path.join(binPath, Platform.isWindows ? 'javac.exe' : 'javac');
        jpackageCmd = path.join(
            binPath, Platform.isWindows ? 'jpackage.exe' : 'jpackage');
        jlinkCmd =
            path.join(binPath, Platform.isWindows ? 'jlink.exe' : 'jlink');
      }

      // Check Java version
      final javaResult = await Process.run(javaCmd, ['--version']);
      final javacResult = await Process.run(javacCmd, ['--version']);
      final jpackageResult = await Process.run(jpackageCmd, ['--version']);
      final jlinkResult = await Process.run(jlinkCmd, ['--version']);

      return JavaEnvironmentInfo(
        javaVersion:
            javaResult.exitCode == 0 ? javaResult.stdout.toString().trim() : '',
        javacVersion: javacResult.exitCode == 0
            ? javacResult.stdout.toString().trim()
            : '',
        hasJpackage: jpackageResult.exitCode == 0,
        hasJlink: jlinkResult.exitCode == 0,
        jdkPath: jdkPath,
        isValid: javaResult.exitCode == 0 && jpackageResult.exitCode == 0,
      );
    } catch (e) {
      return JavaEnvironmentInfo(
        javaVersion: '',
        javacVersion: '',
        hasJpackage: false,
        hasJlink: false,
        jdkPath: jdkPath,
        isValid: false,
        error: e.toString(),
      );
    }
  }

  /// Gets suggested modules for common application types
  /// Similar to the Java version's getSuggestedModules method
  List<String> getSuggestedModules() {
    // Common modules that are often needed, focusing on safe, widely available modules
    return [
      'java.base',
      'java.desktop',
      'java.logging',
      'java.management',
      'java.naming',
      'java.prefs',
      'java.security.jgss',
      'java.sql',
      'java.xml',
      'javafx.controls',
      'javafx.fxml',
      'javafx.base',
      'javafx.graphics',
      'jdk.crypto.ec',
      'jdk.localedata',
      'jdk.unsupported'
    ];
  }

  /// Finds the JavaFX module path on the system
  /// Returns null if JavaFX modules are not found
}

/// Result of JAR file analysis
class JarAnalysisResult {
  final String jarPath;
  final String fileName;
  final int fileSize;
  final String mainClass;
  final Map<String, String> manifest;
  final List<String> dependencies;
  final List<String> modules;
  final Map<String, dynamic> jarInfo;

  JarAnalysisResult({
    required this.jarPath,
    required this.fileName,
    required this.fileSize,
    required this.mainClass,
    required this.manifest,
    required this.dependencies,
    required this.modules,
    required this.jarInfo,
  });

  /// Gets formatted file size
  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    }
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Gets the application name from manifest or filename
  String get suggestedAppName {
    final implTitle = manifest['Implementation-Title'];
    if (implTitle != null && implTitle.isNotEmpty) return implTitle;

    final specTitle = manifest['Specification-Title'];
    if (specTitle != null && specTitle.isNotEmpty) return specTitle;

    return path.basenameWithoutExtension(fileName);
  }

  /// Gets the application version from manifest
  String get suggestedVersion {
    final implVersion = manifest['Implementation-Version'];
    if (implVersion != null && implVersion.isNotEmpty) return implVersion;

    final specVersion = manifest['Specification-Version'];
    if (specVersion != null && specVersion.isNotEmpty) return specVersion;

    return '1.0.0';
  }

  /// Gets the vendor from manifest
  String get suggestedVendor {
    final implVendor = manifest['Implementation-Vendor'];
    if (implVendor != null && implVendor.isNotEmpty) return implVendor;

    final specVendor = manifest['Specification-Vendor'];
    if (specVendor != null && specVendor.isNotEmpty) return specVendor;

    return '';
  }
}

/// Information about Java environment
class JavaEnvironmentInfo {
  final String javaVersion;
  final String javacVersion;
  final bool hasJpackage;
  final bool hasJlink;
  final String jdkPath;
  final bool isValid;
  final String? error;

  JavaEnvironmentInfo({
    required this.javaVersion,
    required this.javacVersion,
    required this.hasJpackage,
    required this.hasJlink,
    required this.jdkPath,
    required this.isValid,
    this.error,
  });

  /// Gets the major Java version number
  int get majorVersion {
    try {
      final match = RegExp(r'(\d+)').firstMatch(javaVersion);
      if (match != null) {
        final version = int.parse(match.group(1)!);
        return version >= 9 ? version : 8;
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return 0;
  }

  /// Checks if Java version supports jpackage
  bool get supportsJpackage => majorVersion >= 14 && hasJpackage;

  /// Checks if Java version supports jlink
  bool get supportsJlink => majorVersion >= 9 && hasJlink;
}
