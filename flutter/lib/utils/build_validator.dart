import 'dart:io';
import '../models/packaroo_project.dart';

class BuildValidator {
  /// Validates that all required build tools are available
  static Future<List<String>> validateBuildEnvironment() async {
    final errors = <String>[];

    // Check Java
    try {
      final javaResult = await Process.run('java', ['-version']);
      if (javaResult.exitCode != 0) {
        errors.add('Java is not installed or not in PATH');
      }
    } catch (e) {
      errors.add('Java is not installed or not in PATH');
    }

    // Check jpackage
    try {
      final jpackageResult = await Process.run('jpackage', ['--version']);
      if (jpackageResult.exitCode != 0) {
        errors.add('jpackage is not available (requires Java 14+)');
      }
    } catch (e) {
      errors.add('jpackage is not available (requires Java 14+)');
    }

    // Check jlink
    try {
      final jlinkResult = await Process.run('jlink', ['--version']);
      if (jlinkResult.exitCode != 0) {
        errors.add('jlink is not available (required for custom runtime)');
      }
    } catch (e) {
      errors.add('jlink is not available (required for custom runtime)');
    }

    return errors;
  }

  /// Quick validation for a project before building
  static List<String> validateProject(PackarooProject project) {
    final errors = <String>[];

    if (project.name.isEmpty) {
      errors.add('Project name is required');
    }

    if (project.jarPath.isEmpty) {
      errors.add('JAR file path is required');
    } else if (!File(project.jarPath).existsSync()) {
      errors.add('JAR file does not exist');
    }

    if (project.mainClass.isEmpty) {
      errors.add('Main class is required');
    }

    if (project.outputPath.isEmpty) {
      errors.add('Output path is required');
    }

    if (project.appVersion.isEmpty) {
      errors.add('App version is required');
    }

    return errors;
  }

  /// Gets build recommendations for a project
  static List<String> getBuildRecommendations(PackarooProject project) {
    final recommendations = <String>[];

    if (project.appVendor.isEmpty) {
      recommendations.add('Consider adding a vendor/publisher name');
    }

    if (project.appDescription.isEmpty) {
      recommendations.add('Consider adding an app description');
    }

    if (project.iconPath.isEmpty) {
      recommendations.add('Consider adding an app icon for better branding');
    }

    if (project.packageType == 'app-image') {
      recommendations.add(
          'Consider building a platform-specific installer (DEB, MSI, DMG)');
    }

    if (!project.useJlink && project.additionalModules.isEmpty) {
      recommendations.add('Consider using JLink to create a smaller runtime');
    }

    return recommendations;
  }
}
