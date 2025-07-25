enum PackageType {
  appImage('app-image', 'Application Image'),
  exe('exe', 'Windows Executable'),
  msi('msi', 'Windows MSI Package'),
  deb('deb', 'Debian Package'),
  rpm('rpm', 'RPM Package'),
  dmg('dmg', 'macOS DMG'),
  pkg('pkg', 'macOS PKG');

  const PackageType(this.value, this.displayName);

  final String value;
  final String displayName;

  static PackageType fromValue(String value) {
    return PackageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PackageType.appImage,
    );
  }

  static List<PackageType> getAvailableTypes() {
    // In a real implementation, this would check the current platform
    // For now, return all types
    return PackageType.values;
  }
}

class JdkInfo {
  final String path;
  final String version;
  final String vendor;
  final bool isValid;

  const JdkInfo({
    required this.path,
    required this.version,
    required this.vendor,
    required this.isValid,
  });

  factory JdkInfo.invalid(String path) {
    return JdkInfo(
      path: path,
      version: 'Unknown',
      vendor: 'Unknown',
      isValid: false,
    );
  }

  @override
  String toString() => '$vendor Java $version';
}

class ModuleInfo {
  final String name;
  final String version;
  final bool isRequired;
  final List<String> dependencies;

  const ModuleInfo({
    required this.name,
    required this.version,
    this.isRequired = false,
    this.dependencies = const [],
  });

  @override
  String toString() => '$name ($version)';
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.valid() {
    return const ValidationResult(isValid: true);
  }

  factory ValidationResult.invalid(List<String> errors,
      [List<String>? warnings]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings ?? [],
    );
  }

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasIssues => hasErrors || hasWarnings;
}
