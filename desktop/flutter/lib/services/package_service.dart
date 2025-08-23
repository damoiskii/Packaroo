import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as path;
import '../models/packaroo_project.dart';
import '../models/build_progress.dart';
import '../models/app_models.dart';
import '../utils/string_utils.dart';
import 'jar_analyzer_service.dart';

class PackageService {
  static const String _jpackageCommand = 'jpackage';
  static const String _jlinkCommand = 'jlink';

  final JarAnalyzerService _jarAnalyzer = JarAnalyzerService();

  /// Validates a project before building
  Future<ValidationResult> validateProjectForBuild(
      PackarooProject project) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Check JAR file exists
    if (project.jarPath.isEmpty) {
      errors.add('JAR file path is required');
    } else {
      final jarFile = File(project.jarPath);
      if (!await jarFile.exists()) {
        errors.add('JAR file not found: ${project.jarPath}');
      }
    }

    // Check main class
    if (project.mainClass.isEmpty) {
      warnings.add('Main class not specified');
    }

    // Check output path
    if (project.outputPath.isEmpty) {
      errors.add('Output path is required');
    } else {
      final outputDir = Directory(project.outputPath);
      try {
        if (!await outputDir.exists()) {
          await outputDir.create(recursive: true);
        }
      } catch (e) {
        errors.add('Cannot create output directory: $e');
      }
    }

    // Check JDK path if specified
    if (project.jdkPath.isNotEmpty) {
      final jdkDir = Directory(project.jdkPath);
      if (!await jdkDir.exists()) {
        errors.add('JDK path not found: ${project.jdkPath}');
      } else {
        // Validate Java environment
        final javaEnv =
            await _jarAnalyzer.validateJavaEnvironment(project.jdkPath);
        if (!javaEnv.isValid) {
          errors.add(
              'Invalid Java environment: ${javaEnv.error ?? "Unknown error"}');
        } else if (!javaEnv.supportsJpackage) {
          errors.add(
              'Java version does not support jpackage (requires Java 14+)');
        }
      }
    }

    // Check package type
    if (project.packageType.isEmpty) {
      warnings.add('Package type not specified');
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Analyzes a JAR file and creates a project
  Future<PackarooProject> analyzeAndCreateProject(String jarPath) async {
    final analysisResult = await _jarAnalyzer.analyzeJar(jarPath);

    // Perform enhanced Spring Boot + JavaFX detection
    final isSpringBootJavaFX =
        await _jarAnalyzer.isSpringBootWithJavaFXApplication(jarPath);
    final isJavaFXApp = await _jarAnalyzer.isJavaFXProject(jarPath);

    // Format the app name to title case
    final formattedAppName =
        StringUtils.toTitleCase(analysisResult.suggestedAppName);

    // Create appropriate description based on project type
    String projectDescription = '';
    if (isSpringBootJavaFX) {
      projectDescription = 'Spring Boot application with JavaFX desktop UI';
    } else if (analysisResult.mainClass
        .contains('org.springframework.boot.loader')) {
      projectDescription = 'Spring Boot application';
    } else if (isJavaFXApp) {
      projectDescription = 'JavaFX desktop application';
    } else {
      projectDescription = 'Java application';
    }

    print('Project analysis complete:');
    print('  - Spring Boot + JavaFX: $isSpringBootJavaFX');
    print('  - JavaFX application: $isJavaFXApp');
    print('  - Main class: ${analysisResult.mainClass}');
    print('  - Project type: $projectDescription');
    print(
        '  - Using Spring Boot launcher: ${analysisResult.mainClass.contains('org.springframework.boot.loader')}');

    // Determine if JLink should be disabled for Spring Boot applications
    final isSpringBootApp =
        analysisResult.mainClass.contains('org.springframework.boot.loader');
    final shouldDisableJLink = isSpringBootApp;

    if (shouldDisableJLink) {
      print(
          '  - JLink disabled: Spring Boot applications work better with full JRE');
    }

    final project = PackarooProject(
      name: formattedAppName,
      description: projectDescription,
      projectPath: path.dirname(jarPath),
      outputPath: path.join(path.dirname(jarPath), 'dist'),
      jarPath: jarPath,
      mainClass: analysisResult.mainClass,
      appName: formattedAppName,
      appVersion: analysisResult.suggestedVersion,
      appDescription: projectDescription, // Use the same description for the app
      appVendor: analysisResult.suggestedVendor,
      additionalModules: analysisResult.modules,
      useJlink: !shouldDisableJLink, // Disable JLink for Spring Boot apps
    );

    return project;
  }

  /// Builds packages for multiple platforms
  Future<List<BuildProgress>> buildForAllPlatforms(
    PackarooProject project,
    List<String> targetPlatforms,
    Function(BuildProgress) onProgressUpdate,
  ) async {
    final builds = <BuildProgress>[];

    for (final platform in targetPlatforms) {
      final platformProject = _createPlatformProject(project, platform);
      final build = await buildPackage(platformProject, onProgressUpdate);
      builds.add(build);
    }

    return builds;
  }

  /// Creates a platform-specific project configuration
  PackarooProject _createPlatformProject(
      PackarooProject base, String platform) {
    final selectedPackageType =
        _getValidPackageTypeForPlatform(base.packageType, platform);

    final platformProject = PackarooProject(
      id: '${base.id}_$platform',
      name: base.name,
      description: base.description,
      projectPath: base.projectPath,
      outputPath: path.join(base.outputPath, platform),
      jarPath: base.jarPath,
      mainClass: base.mainClass,
      modulePath: base.modulePath,
      jdkPath: base.jdkPath,
      appName: base.appName,
      appVersion: base.appVersion,
      appDescription: base.appDescription,
      appVendor: base.appVendor,
      appCopyright: base.appCopyright,
      iconPath: base.iconPath,
      packageType: selectedPackageType,
      jvmOptions: List.from(base.jvmOptions),
      appArguments: List.from(base.appArguments),
      additionalModules: List.from(base.additionalModules),
      useJlink: base.useJlink,
      includeAllModules: base.includeAllModules,
      stripDebug: base.stripDebug,
      compress: base.compress,
      noHeaderFiles: base.noHeaderFiles,
      noManPages: base.noManPages,
    );

    return platformProject;
  }

  /// Gets default package type for platform
  String _getDefaultPackageType(String platform) {
    switch (platform.toLowerCase()) {
      case 'windows':
        return 'msi';
      case 'macos':
        return 'dmg';
      case 'linux':
        return 'deb';
      default:
        return 'app-image';
    }
  }

  /// Gets a valid package type for the platform, respecting user choice
  String _getValidPackageTypeForPlatform(String selectedType, String platform) {
    // If user selected app-image, it's always valid
    if (selectedType == 'app-image') {
      return selectedType;
    }

    // Check if the selected type is valid for the current platform
    final validTypes = _getValidPackageTypesForPlatform(platform);
    if (validTypes.contains(selectedType)) {
      return selectedType;
    }

    // If not valid, fall back to default for the platform
    return _getDefaultPackageType(platform);
  }

  /// Gets list of valid package types for a platform
  List<String> _getValidPackageTypesForPlatform(String platform) {
    switch (platform.toLowerCase()) {
      case 'windows':
        return ['app-image', 'msi', 'exe'];
      case 'macos':
        return ['app-image', 'dmg', 'pkg'];
      case 'linux':
        return ['app-image', 'deb', 'rpm'];
      default:
        return ['app-image'];
    }
  }

  /// Builds a package using jpackage
  Future<BuildProgress> buildPackage(
    PackarooProject project,
    Function(BuildProgress) onProgressUpdate,
  ) async {
    print(
        'PackageService.buildPackage: Starting build for project ${project.name}');

    final buildProgress = BuildProgress(
      id: 'build_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      status: BuildStatus.running,
    );

    try {
      print(
          'PackageService.buildPackage: Calling onProgressUpdate with initial progress');
      onProgressUpdate(buildProgress);
      buildProgress.addLog('Starting package build for ${project.name}');

      // Validate project
      buildProgress.updateProgress(0.1, 'Validating project');
      onProgressUpdate(buildProgress);
      print('PackageService.buildPackage: Starting validation');

      final validation = await validateProjectForBuild(project);
      print(
          'PackageService.buildPackage: Validation result - isValid: ${validation.isValid}, errors: ${validation.errors}');

      if (!validation.isValid) {
        final errorMsg = 'Validation failed: ${validation.errors.join(', ')}';
        print(
            'PackageService.buildPackage: Build failed due to validation errors: $errorMsg');
        buildProgress.fail(errorMsg);
        onProgressUpdate(buildProgress);
        return buildProgress;
      }

      // Create jlink runtime if needed
      if (project.useJlink) {
        buildProgress.updateProgress(0.2, 'Creating JLink runtime');
        onProgressUpdate(buildProgress);
        print('PackageService.buildPackage: Creating JLink runtime');

        await _createJlinkRuntime(project, buildProgress, onProgressUpdate);
      }

      // Build with jpackage
      buildProgress.updateProgress(0.6, 'Running jpackage');
      onProgressUpdate(buildProgress);
      print('PackageService.buildPackage: Starting jpackage');

      await _runJpackage(project, buildProgress, onProgressUpdate);
      print('PackageService.buildPackage: jpackage completed');

      // Complete the build
      final outputPath = path.join(project.outputPath, project.appName);
      buildProgress.complete(outputPath);
      onProgressUpdate(buildProgress);
      print(
          'PackageService.buildPackage: Build completed successfully, output: $outputPath');
    } catch (e, stackTrace) {
      print('PackageService.buildPackage: ERROR - $e');
      print('PackageService.buildPackage: STACK TRACE - $stackTrace');
      buildProgress.fail('Build failed: $e');
      buildProgress.addLog('Stack trace: $stackTrace');
      onProgressUpdate(buildProgress);
    }

    return buildProgress;
  }

  /// Creates a JLink runtime
  Future<void> _createJlinkRuntime(
    PackarooProject project,
    BuildProgress progress,
    Function(BuildProgress) onProgressUpdate,
  ) async {
    final runtimePath = path.join(project.outputPath, 'runtime');

    // Clean up existing runtime
    final runtimeDir = Directory(runtimePath);
    if (await runtimeDir.exists()) {
      await runtimeDir.delete(recursive: true);
    }

    final jlinkArgs = <String>[
      '--output',
      runtimePath,
      '--strip-debug',
      if (project.compress) '--compress=2',
      if (project.noHeaderFiles) '--no-header-files',
      if (project.noManPages) '--no-man-pages',
    ];

    // Add modules
    if (project.includeAllModules) {
      jlinkArgs.addAll(['--add-modules', 'ALL-MODULE-PATH']);
    } else if (project.additionalModules.isNotEmpty) {
      jlinkArgs.addAll(['--add-modules', project.additionalModules.join(',')]);
    } else {
      // Default modules for non-modular applications
      jlinkArgs.addAll(['--add-modules', 'java.base,java.desktop']);
    }

    // Add module path
    if (project.modulePath.isNotEmpty) {
      jlinkArgs.addAll(['--module-path', project.modulePath]);
    }

    progress.addLog('JLink command: $_jlinkCommand ${jlinkArgs.join(' ')}');

    final result = await Process.run(_jlinkCommand, jlinkArgs);

    progress.addLog('JLink stdout: ${result.stdout}');
    progress.addLog('JLink stderr: ${result.stderr}');
    progress.addLog('JLink exit code: ${result.exitCode}');

    if (result.exitCode != 0) {
      throw Exception(
          'JLink failed with exit code ${result.exitCode}: ${result.stderr.toString().isEmpty ? result.stdout : result.stderr}');
    }

    progress.addLog('JLink runtime created successfully');
    progress.updateProgress(0.5, 'JLink runtime created');
    onProgressUpdate(progress);
  }

  /// Runs jpackage to create the final package
  Future<void> _runJpackage(
    PackarooProject project,
    BuildProgress progress,
    Function(BuildProgress) onProgressUpdate,
  ) async {
    final jpackageArgs = <String>[
      '--input',
      path.dirname(project.jarPath),
      '--main-jar',
      path.basename(project.jarPath),
      '--main-class',
      project.mainClass,
      '--dest',
      project.outputPath,
      '--name',
      project.appName,
      '--app-version',
      project.appVersion,
    ];

    // Add optional parameters
    if (project.appDescription.isNotEmpty) {
      jpackageArgs.addAll(['--description', project.appDescription]);
    }

    if (project.appVendor.isNotEmpty) {
      jpackageArgs.addAll(['--vendor', project.appVendor]);
    }

    if (project.appCopyright.isNotEmpty) {
      jpackageArgs.addAll(['--copyright', project.appCopyright]);
    }

    if (project.iconPath.isNotEmpty) {
      jpackageArgs.addAll(['--icon', project.iconPath]);
    }

    // Package type
    if (project.packageType != 'app-image') {
      jpackageArgs.addAll(['--type', project.packageType]);
    }

    // JVM options
    final jvmOptions = List<String>.from(project.jvmOptions);

    // Add all JVM options
    for (final option in jvmOptions) {
      jpackageArgs.addAll(['--java-options', option]);
    }

    // App arguments
    if (project.appArguments.isNotEmpty) {
      for (final arg in project.appArguments) {
        jpackageArgs.addAll(['--arguments', arg]);
      }
    }

    // Runtime path (if using JLink)
    if (project.useJlink) {
      final runtimePath = path.join(project.outputPath, 'runtime');
      jpackageArgs.addAll(['--runtime-image', runtimePath]);
    }

    progress.addLog(
        'JPackage command: $_jpackageCommand ${jpackageArgs.join(' ')}');

    // Run jpackage with real-time output
    final process = await Process.start(_jpackageCommand, jpackageArgs);

    process.stdout.transform(utf8.decoder).listen((data) {
      progress.addLog('STDOUT: $data');
      progress.updateProgress(0.8, 'Creating package...');
      onProgressUpdate(progress);
    });

    process.stderr.transform(utf8.decoder).listen((data) {
      progress.addLog('STDERR: $data');
    });

    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      throw Exception('JPackage failed with exit code $exitCode');
    }

    progress.addLog('JPackage completed successfully');
    progress.updateProgress(0.9, 'Package created successfully');
    onProgressUpdate(progress);
  }

  /// Validates a project before building
  Future<ValidationResult> validateProject(PackarooProject project) async {
    final errors = <String>[];
    final warnings = <String>[];

    // Check required fields
    if (project.name.isEmpty) {
      errors.add('Project name is required');
    }

    if (project.jarPath.isEmpty) {
      errors.add('JAR file path is required');
    } else if (!await File(project.jarPath).exists()) {
      errors.add('JAR file does not exist: ${project.jarPath}');
    }

    if (project.mainClass.isEmpty) {
      errors.add('Main class is required');
    }

    if (project.outputPath.isEmpty) {
      errors.add('Output path is required');
    }

    // Check output directory
    try {
      final outputDir = Directory(project.outputPath);
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }
    } catch (e) {
      errors.add('Cannot create output directory: $e');
    }

    // Check icon file
    if (project.iconPath.isNotEmpty) {
      if (!await File(project.iconPath).exists()) {
        warnings.add('Icon file does not exist: ${project.iconPath}');
      }
    }

    // Check JDK
    if (project.jdkPath.isNotEmpty) {
      final jdkValid = await _validateJdk(project.jdkPath);
      if (!jdkValid) {
        warnings.add('JDK path may not be valid: ${project.jdkPath}');
      }
    }

    // Check if jpackage is available
    try {
      final result = await Process.run(_jpackageCommand, ['--version']);
      if (result.exitCode != 0) {
        errors.add('jpackage command not found or not working');
      }
    } catch (e) {
      errors.add('jpackage command not available: $e');
    }

    // Check if jlink is available (if needed)
    if (project.useJlink) {
      try {
        final result = await Process.run(_jlinkCommand, ['--version']);
        if (result.exitCode != 0) {
          errors.add('jlink command not found or not working');
        }
      } catch (e) {
        errors.add('jlink command not available: $e');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
    );
  }

  /// Validates a JDK installation
  Future<bool> _validateJdk(String jdkPath) async {
    try {
      final javaExe = Platform.isWindows
          ? path.join(jdkPath, 'bin', 'java.exe')
          : path.join(jdkPath, 'bin', 'java');

      final result = await Process.run(javaExe, ['-version']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  /// Gets JDK information
  Future<JdkInfo> getJdkInfo(String jdkPath) async {
    try {
      final javaExe = Platform.isWindows
          ? path.join(jdkPath, 'bin', 'java.exe')
          : path.join(jdkPath, 'bin', 'java');

      final result = await Process.run(javaExe, ['-version']);

      if (result.exitCode == 0) {
        final output = result.stderr as String;
        final lines = output.split('\n');

        String version = 'Unknown';
        String vendor = 'Unknown';

        for (final line in lines) {
          if (line.contains('version')) {
            final versionMatch = RegExp(r'"([^"]+)"').firstMatch(line);
            if (versionMatch != null) {
              version = versionMatch.group(1) ?? 'Unknown';
            }
          }
          if (line.contains('OpenJDK') || line.contains('Oracle')) {
            vendor = line.trim();
          }
        }

        return JdkInfo(
          path: jdkPath,
          version: version,
          vendor: vendor,
          isValid: true,
        );
      }
    } catch (e) {
      // Ignore errors
    }

    return JdkInfo.invalid(jdkPath);
  }

  /// Discovers available JDK installations
  Future<List<JdkInfo>> discoverJdks() async {
    final jdks = <JdkInfo>[];
    final potentialPaths = <String>[];

    if (Platform.isWindows) {
      potentialPaths.addAll([
        'C:\\Program Files\\Java',
        'C:\\Program Files (x86)\\Java',
        'C:\\Program Files\\Eclipse Adoptium',
        'C:\\Program Files\\Eclipse Foundation',
      ]);
    } else if (Platform.isMacOS) {
      potentialPaths.addAll([
        '/Library/Java/JavaVirtualMachines',
        '/System/Library/Java/JavaVirtualMachines',
        '/usr/local/Cellar',
      ]);
    } else {
      potentialPaths.addAll([
        '/usr/lib/jvm',
        '/usr/java',
        '/opt/java',
      ]);
    }

    for (final basePath in potentialPaths) {
      final dir = Directory(basePath);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is Directory) {
            final jdkInfo = await getJdkInfo(entity.path);
            if (jdkInfo.isValid) {
              jdks.add(jdkInfo);
            }
          }
        }
      }
    }

    return jdks;
  }

  /// Checks if a project is a JavaFX application
  bool _isJavaFXProject(PackarooProject project) {
    // Check if any of the required modules are JavaFX modules
    if (project.additionalModules
        .any((module) => module.startsWith('javafx.'))) {
      return true;
    }

    // Check if the main class indicates JavaFX usage
    if (project.mainClass.contains('javafx') ||
        project.mainClass.contains('JavaFX')) {
      return true;
    }

    // Check if it's a Spring Boot launcher (common for Spring Boot + JavaFX apps)
    if (project.mainClass.contains('org.springframework.boot.loader')) {
      // For Spring Boot apps, also check the JAR name or other indicators
      final jarName = path.basename(project.jarPath).toLowerCase();
      if (jarName.contains('desktop') ||
          jarName.contains('fx') ||
          jarName.contains('javafx')) {
        return true;
      }

      // If Spring Boot has JavaFX modules, it's likely a JavaFX app
      return project.additionalModules
          .any((module) => module.startsWith('javafx.'));
    }

    return false;
  }

  /// Enhanced method to check if a project is a Spring Boot + JavaFX application
  /// This uses the comprehensive detection from JarAnalyzerService
  Future<bool> isSpringBootWithJavaFXProject(PackarooProject project) async {
    try {
      return await _jarAnalyzer
          .isSpringBootWithJavaFXApplication(project.jarPath);
    } catch (e) {
      print('Error checking Spring Boot + JavaFX: $e');
      // Fallback to the basic method
      return _isJavaFXProject(project) &&
          project.mainClass.contains('org.springframework.boot.loader');
    }
  }

  /// Enhanced method to check if a project is a JavaFX application
  /// This uses the comprehensive detection from JarAnalyzerService
  Future<bool> isJavaFXProject(PackarooProject project) async {
    try {
      // First check the basic indicators for quick detection
      if (_isJavaFXProject(project)) {
        return true;
      }

      // If basic check fails, use the comprehensive JAR analysis
      return await _jarAnalyzer.isJavaFXProject(project.jarPath);
    } catch (e) {
      print('Error checking JavaFX project: $e');
      // Fallback to the basic method
      return _isJavaFXProject(project);
    }
  }
}
