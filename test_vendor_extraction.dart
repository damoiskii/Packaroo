void main() {
  // Test the vendor extraction logic with your example
  final testCases = [
    {
      'description': 'Your example - should extract "Moiskii"',
      'startClass': 'com.moiskii.mavenbot.App',
      'mainClass': 'org.springframework.boot.loader.launch.JarLauncher',
      'expected': 'Moiskii'
    },
    {
      'description':
          'Original test case - should extract "Test" from start class',
      'startClass': 'com.test.TestApp',
      'mainClass': 'org.springframework.boot.loader.JarLauncher',
      'expected': 'Test'
    },
    {
      'description': 'No start class - should fall back to main class',
      'startClass': null,
      'mainClass': 'com.mycompany.myapp.Main',
      'expected': 'Mycompany'
    },
    {
      'description': 'Real Spring Boot example',
      'startClass': 'com.moiskii.mavenbot.MavenBotApplication',
      'mainClass': 'org.springframework.boot.loader.launch.JarLauncher',
      'expected': 'Moiskii'
    },
  ];

  for (final testCase in testCases) {
    final vendor = getSuggestedVendor(
      startClass: testCase['startClass'] as String?,
      mainClass: testCase['mainClass'] as String,
    );
    final expected = testCase['expected'] as String;
    final description = testCase['description'] as String;

    print('$description');
    print('  Start-Class: ${testCase['startClass']}');
    print('  Main-Class: ${testCase['mainClass']}');
    print('  Expected: "$expected", Got: "$vendor"');
    print('  Result: ${vendor == expected ? "✅ PASS" : "❌ FAIL"}');
    print('');
  }
}

String getSuggestedVendor({String? startClass, required String mainClass}) {
  // Simulate the logic from suggestedVendor getter
  // No manifest vendors for this test

  // Fallback: try to extract vendor from Start-Class first (actual app class), then Main-Class
  if (startClass != null && startClass.isNotEmpty) {
    final vendorFromStartClass = extractVendorFromMainClass(startClass);
    if (vendorFromStartClass.isNotEmpty) return vendorFromStartClass;
  }

  final vendorFromMainClass = extractVendorFromMainClass(mainClass);
  if (vendorFromMainClass.isNotEmpty) return vendorFromMainClass;

  return '';
}

String extractVendorFromMainClass(String? mainClass) {
  try {
    if (mainClass == null || mainClass.trim().isEmpty) {
      return '';
    }

    // Split the main class by dots to get package parts
    final parts = mainClass.split('.');

    // Look for common package patterns like com.vendor.app or org.vendor.app
    if (parts.length >= 3) {
      final firstPart = parts[0].toLowerCase();

      // Handle common package prefixes
      if (firstPart == 'com' ||
          firstPart == 'org' ||
          firstPart == 'net' ||
          firstPart == 'io') {
        // Vendor is typically the second part
        final vendor = parts[1];
        return formatVendorName(vendor);
      } else {
        // If no standard prefix, use the first part as vendor
        return formatVendorName(parts[0]);
      }
    } else if (parts.length >= 2) {
      // For shorter packages, use the first part
      return formatVendorName(parts[0]);
    }

    return '';
  } catch (e) {
    print('Could not extract vendor from main class: $mainClass, error: $e');
    return '';
  }
}

String formatVendorName(String vendor) {
  if (vendor.trim().isEmpty) {
    return '';
  }

  // Remove any special characters and numbers
  vendor = vendor.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');

  if (vendor.isEmpty) {
    return '';
  }

  // Convert to title case - first letter uppercase, rest lowercase
  return vendor[0].toUpperCase() + vendor.substring(1).toLowerCase();
}
