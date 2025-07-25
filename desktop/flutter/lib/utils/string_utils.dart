class StringUtils {
  /// Converts a string to title case
  /// Examples:
  /// - 'substringa-substringb' becomes 'Substringa Substringb'
  /// - 'hello world' becomes 'Hello World'
  /// - 'my_app_name' becomes 'My App Name'
  static String toTitleCase(String input) {
    if (input.isEmpty) return input;

    // Replace common separators with spaces
    String normalized = input
        .replaceAll(RegExp(r'[-_\.]+'), ' ')
        .replaceAll(RegExp(r'([a-z])([A-Z])'), r'$1 $2') // Handle camelCase
        .toLowerCase();

    // Split into words and capitalize each
    return normalized
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Converts a title case string back to a valid identifier
  /// Examples:
  /// - 'Hello World' becomes 'hello-world'
  /// - 'My App Name' becomes 'my-app-name'
  static String toIdentifier(String input) {
    if (input.isEmpty) return input;

    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), ''); // Remove leading/trailing dashes
  }

  /// Validates if a string is a valid version number
  static bool isValidVersion(String version) {
    final versionRegex = RegExp(r'^\d+(\.\d+)*(-\w+)?$');
    return versionRegex.hasMatch(version);
  }
}
