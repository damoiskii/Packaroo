# Packaroo Desktop - Complete User Manual

## Table of Contents
1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Interface Overview](#interface-overview)
4. [File Selection](#file-selection)
5. [Application Configuration](#application-configuration)
6. [JAR Analysis](#jar-analysis)
7. [Module Management (JLink)](#module-management-jlink)
8. [Advanced Options](#advanced-options)
9. [Packaging](#packaging)
10. [Configuration Management](#configuration-management)
11. [Presets](#presets)
12. [Console and Logging](#console-and-logging)
13. [Themes](#themes)
14. [Setup Guide](#setup-guide)
15. [Menu Reference](#menu-reference)
16. [Troubleshooting](#troubleshooting)
17. [Tips and Best Practices](#tips-and-best-practices)

---

## Introduction

**Packaroo Desktop** is a modern JavaFX application packaging tool that simplifies the process of creating native application packages from JAR files. It provides a comprehensive GUI for configuring and building applications using Java's `jpackage` and `jlink` tools, with support for multiple platforms and output formats.

### Key Features
- **JAR Dependency Analysis**: Automatically analyze JAR files to detect main classes, modules, and manifest information
- **Auto-Population**: Smart field population from JAR filenames and manifest data
- **JLink Integration**: Create custom JRE distributions with only required modules
- **Cross-Platform Support**: Package for Windows, macOS, and Linux
- **Multiple Output Formats**: Support for installers, app images, and more
- **Configuration Management**: Save and load packaging configurations
- **Preset System**: Create reusable configuration templates
- **Dark/Light Themes**: Modern UI with theme switching
- **Structured Logging**: Organized console output with categorized messages
- **Setup Guide**: Built-in help for configuring Java tools

---

## Getting Started

### Prerequisites
- **Java 17 or higher** (for running Packaroo)
- **JDK 14 or higher** (for jpackage functionality)
- **Platform-specific tools** (varies by target platform)

### Running Packaroo
1. Navigate to the Packaroo directory
2. Run the application:
   ```bash
   ./mvnw javafx:run
   ```
   Or if you have a packaged JAR:
   ```bash
   java -jar packaroo-desktop-1.0.0.jar
   ```

### First Launch
On first launch, Packaroo will:
1. Display an animated splash screen
2. Initialize the Spring Boot context
3. Check for required Java tools (jpackage, jlink)
4. Display warnings if tools are missing
5. Open the main application window

---

## Interface Overview

The Packaroo main window is organized into several sections:

### Menu Bar
- **File**: Configuration management (New, Open, Save, Exit)
- **Tools**: Quick access to analysis and packaging functions
- **View**: Theme switching and view management
- **Help**: Setup guide and about information

### Main Content Areas
1. **File Selection Panel**: Choose JAR, icon, and output directory
2. **Application Configuration**: App name, version, vendor, etc.
3. **Platform & Format**: Target platform and output format selection
4. **JLink Configuration**: Module selection and custom runtime options
5. **Advanced Options**: JVM and application arguments
6. **Actions Panel**: Analysis, packaging, and reset buttons
7. **Presets Panel**: Save and load configuration presets
8. **Console**: Structured logging output with categorized messages

---

## File Selection

### JAR File Selection
1. Click **"Browse"** next to the JAR File field
2. Select your application's JAR file
3. **Auto-population occurs**: App name, version, and vendor are automatically extracted from the filename
4. **Output directory is set**: Based on the app name (e.g., `~/Desktop/MyAppBuildOutput`)
5. **Preset name is suggested**: App name + "Preset" (e.g., "MyApp Preset")

**Filename Parsing Examples:**
- `my-app-1.0.0.jar` → App: "My App", Version: "1.0.0"
- `calculator-v2.1.jar` → App: "Calculator", Version: "v2.1"
- `simple-tool.jar` → App: "Simple Tool", Version: ""

### Icon File Selection
1. Click **"Browse"** next to the Icon File field
2. Choose an icon file (PNG, ICO, JPG, GIF supported)
3. **Platform recommendations**:
   - **Windows**: Use ICO format (256x256 or multiple sizes)
   - **macOS**: Use PNG format (1024x1024 recommended)
   - **Linux**: Use PNG format (512x512 recommended)

### Output Directory Selection
1. Click **"Browse"** next to the Output Directory field
2. Choose where the packaged application will be created
3. **Auto-suggestion**: Based on app name in `~/Desktop/[AppName]BuildOutput`
4. **Directory creation**: Will be created if it doesn't exist

---

## Application Configuration

### Required Fields
- **Application Name**: The display name of your application
- **Version**: Application version (e.g., "1.0.0", "2.1-beta")
- **Main Class**: The fully qualified main class name (e.g., `com.example.MyApp`)

### Optional Fields
- **Vendor**: Company or developer name (auto-populated from package name)
- **Description**: Detailed application description (populated from manifest or configs)
- **Copyright**: Copyright notice for the application

### Auto-Population Behavior
1. **From JAR filename**: Basic app name and version extraction
2. **From JAR manifest**: Reads Implementation-Title, Implementation-Version, etc.
3. **From package structure**: Extracts vendor from main class package
4. **Priority order**: Manifest data overrides filename data when available

---

## JAR Analysis

### Starting Analysis
1. Select a JAR file
2. Click **"Analyze JAR"** button or use **Tools → Analyze JAR**
3. Monitor progress in the console

### What Analysis Provides
- **Main Class Detection**: Finds the application entry point
- **Start Class Detection**: Identifies Spring Boot start class if present
- **Required Modules**: Lists JDK modules needed by the application
- **Missing Modules**: Identifies modules not available in current JDK
- **Manifest Information**: Extracts metadata from JAR manifest
- **Dependency Information**: Basic dependency structure

### Analysis Output
The console will show structured output like:
```
[12:34:56] 🔍 [ANALYSIS] Starting analysis of: my-app.jar
[12:34:57] ✅ [ANALYSIS] Analysis completed successfully!
[12:34:57] ℹ️ [CONFIG] Detected main class: com.example.MyApp
[12:34:57] ℹ️ [MODULES] Required modules: 5
[12:34:57] ℹ️ [MODULES]   - java.base
[12:34:57] ℹ️ [MODULES]   - java.desktop
```

### Post-Analysis Actions
- **Module list updates**: Required modules are automatically selected
- **Field population**: Main class and other fields are filled
- **Vendor extraction**: Package-based vendor detection
- **Configuration override**: Manifest data takes precedence

---

## Module Management (JLink)

### Enabling JLink
1. Check **"Enable JLink"** checkbox
2. Module selection becomes available
3. Creates a custom JRE with only selected modules

### Module Selection
- **Auto-selected**: Required modules from analysis are pre-selected
- **Manual selection**: Check/uncheck modules in the list
- **Custom modules**: Add modules not in the standard list

### Adding Custom Modules
1. Type module name in the "Custom Module" field
2. Click **"Add Module"** button
3. Module appears in the list and is automatically selected

### Benefits of JLink
- **Smaller distribution**: Only includes necessary JRE components
- **Faster startup**: Reduced JRE overhead
- **Self-contained**: No external JRE dependency
- **Security**: Fewer attack vectors with minimal JRE

### Module Categories
- **java.base**: Core Java functionality (always required)
- **java.desktop**: Swing/AWT GUI components
- **java.logging**: Java logging framework
- **javafx.controls**: JavaFX UI controls
- **And many more**: See the full list in the application

---

## Advanced Options

### JVM Arguments
Add custom JVM options, one per line:
```
-Xmx2g
-Dfile.encoding=UTF-8
-Djava.awt.headless=false
--add-opens java.base/java.lang=ALL-UNNAMED
```

**Common JVM Arguments:**
- **Memory**: `-Xmx2g` (max heap), `-Xms512m` (initial heap)
- **System Properties**: `-Dproperty=value`
- **Module System**: `--add-opens`, `--add-exports`
- **GC Tuning**: `-XX:+UseG1GC`, `-XX:MaxGCPauseMillis=200`

### Application Arguments
Add command-line arguments for your application:
```
--config=/path/to/config
--verbose
--port=8080
```

---

## Packaging

### Platform Selection
Choose your target platform:
- **CURRENT**: Package for the current operating system
- **WINDOWS**: Create Windows-specific packages
- **MACOS**: Create macOS-specific packages  
- **LINUX**: Create Linux-specific packages

### Output Format Selection
Available formats vary by platform:

**Windows:**
- **APP_IMAGE**: Portable application directory
- **EXE**: Windows executable installer
- **MSI**: Microsoft Installer package

**macOS:**
- **APP_IMAGE**: macOS app bundle (.app)
- **DMG**: Disk image installer
- **PKG**: macOS installer package

**Linux:**
- **APP_IMAGE**: Portable application directory
- **DEB**: Debian package (.deb)
- **RPM**: Red Hat package (.rpm)

### Starting Packaging
1. Ensure all required fields are filled
2. Click **"Package Application"** button
3. Monitor progress with animated progress bar
4. View detailed output in the console

### Packaging Process
The console shows structured progress:
```
[12:35:00] ═══════════════════════════════════════
[12:35:00] ✅ [BUILD] PACKAGING COMPLETED SUCCESSFULLY!
[12:35:00] ℹ️ [BUILD] Output location: /path/to/output
[12:35:00] ℹ️ [BUILD] Execution time: 15230 ms
[12:35:00] ═══════════════════════════════════════
```

### Output Location
Packaged applications are created in the specified output directory:
- **APP_IMAGE**: Directory containing the application
- **Installers**: Single installer file (EXE, MSI, DMG, DEB, RPM)

---

## Configuration Management

### Saving Configurations
1. **File → Save Configuration** or **Ctrl+S**
2. Choose location and filename
3. **Auto-naming**: Based on app name (e.g., "MyApp Config.json")
4. **Format**: JSON configuration file

### Loading Configurations
1. **File → Open Configuration** or **Ctrl+O**
2. Select a JSON configuration file
3. **All fields populate**: Including description if present
4. **Console confirmation**: Shows successful load message

### Configuration Contents
Saved configurations include:
- All file paths (JAR, icon, output directory)
- Application metadata (name, version, vendor, description, copyright)
- Platform and format selections
- JLink settings and module selections
- JVM and application arguments

### Auto-Save Behavior
- **No auto-save**: Configurations must be manually saved
- **Unsaved changes**: No warning currently (planned feature)
- **Default config**: Loads blank configuration on startup

---

## Presets

Presets are simplified configuration templates for common packaging scenarios.

### Creating Presets
1. Configure your packaging settings
2. Enter a name in the **"Preset Name"** field
3. Click **"Save Preset"** button
4. **Auto-naming**: App name + "Preset" when JAR is selected

### Loading Presets
1. Select a preset from the **"Presets"** dropdown
2. Click **"Load Preset"** button
3. **Configuration applies**: All settings from preset are loaded
4. **Confirmation dialog**: Shows successful load

### Managing Presets
- **Delete**: Select preset and click "Delete Preset"
- **Overwrite**: Save with same name to update existing preset
- **List refresh**: Automatically updates when presets change

### Preset vs Configuration Difference
- **Presets**: Quick templates stored in app data
- **Configurations**: Full project files saved anywhere
- **Use presets for**: Common packaging patterns
- **Use configurations for**: Complete project state

---

## Console and Logging

### Structured Output
The console uses a sophisticated logging system with:
- **Timestamps**: Precise timing for each message
- **Categories**: SYSTEM, ANALYSIS, CONFIG, BUILD, MODULES, UI
- **Log Levels**: INFO (ℹ️), SUCCESS (✅), WARNING (⚠️), ERROR (❌), DEBUG (🔍)
- **Visual Separators**: Section dividers for major operations

### Message Categories
- **SYSTEM**: Application startup, tool availability
- **ANALYSIS**: JAR analysis progress and results  
- **CONFIG**: Configuration loading, field population
- **BUILD**: Packaging process and results
- **MODULES**: Module detection and selection
- **UI**: User interface actions and state changes

### Console Actions
- **Clear**: Click "Clear Console" to remove all messages
- **Export**: Save console output to a text file
- **Auto-scroll**: Console automatically scrolls to show latest messages

### Log Message Examples
```
[12:34:56] ℹ️ [SYSTEM] Packaroo application initialized successfully
[12:35:15] 🔍 [ANALYSIS] Starting analysis of: calculator.jar
[12:35:16] ✅ [ANALYSIS] Analysis completed successfully!
[12:35:16] ℹ️ [CONFIG] Set app name from manifest: Calculator Pro
[12:35:45] ⚠️ [SYSTEM] jlink tool is not available. JLink features will be disabled.
```

---

## Themes

### Theme Options
- **Light Theme**: Default bright theme with light backgrounds
- **Dark Theme**: Modern dark theme with dark backgrounds and light text

### Switching Themes
1. **View → Dark Theme** checkbox in menu bar
2. **Immediate application**: Theme changes instantly
3. **Persistent**: Theme preference is saved and restored on restart

### Theme Scope
- **Main window**: All UI components respect the theme
- **Setup guide**: Has its own theme-aware styling
- **Console**: Uses theme-appropriate colors for different message types
- **Dialogs**: Standard system dialogs (not themed)

---

## Setup Guide

### Accessing Setup Guide
1. **Help → Setup Guide** from menu bar
2. **Dedicated view**: Separate screen with comprehensive setup instructions
3. **Navigation**: "Back to Main" button to return

### Content Areas
The setup guide provides detailed instructions for:

**Windows Setup:**
- JDK installation and configuration
- jpackage tool verification
- WiX Toolset for MSI installers
- Inno Setup for advanced installers

**macOS Setup:**
- Xcode Command Line Tools
- JDK installation options
- Code signing requirements
- Notarization process

**Linux Setup:**
- JDK installation via package managers
- Development tools installation
- Distribution-specific packaging tools

### Interactive Features
- **Copy buttons**: Click to copy commands to clipboard
- **Collapsible sections**: Expand/collapse instruction sections
- **Platform-specific**: Shows relevant information for each OS
- **Version detection**: Includes commands to verify tool installation

---

## Menu Reference

### File Menu
- **New Configuration** (Ctrl+N): Reset all settings to defaults
- **Open Configuration** (Ctrl+O): Load a saved configuration file
- **Save Configuration** (Ctrl+S): Save current settings to file
- **Exit** (Ctrl+Q): Close the application

### Tools Menu
- **Analyze JAR** (F5): Start JAR dependency analysis
- **Package Application** (F6): Begin the packaging process
- **Clear Console** (Ctrl+L): Clear all console messages

### View Menu  
- **Dark Theme**: Toggle between light and dark themes
- **Back to Main**: Return to main view (when in setup guide)

### Help Menu
- **Setup Guide**: Open the comprehensive setup instructions
- **About**: Show application version and information

---

## Troubleshooting

### Common Issues

#### "jpackage tool is not available"
**Cause**: JDK 14+ is not installed or not in PATH
**Solution**: 
1. Install JDK 14 or higher
2. Verify with: `jpackage --version`
3. Check PATH environment variable

#### "jlink tool is not available"  
**Cause**: JDK installation is incomplete or JRE-only
**Solution**:
1. Install full JDK (not just JRE)
2. Verify with: `jlink --version`

#### Analysis fails with "Cannot access JAR file"
**Cause**: JAR file is locked, corrupted, or permissions issue
**Solution**:
1. Close any applications using the JAR
2. Check file permissions
3. Try copying JAR to a different location

#### Packaging fails with "Output directory not writable"
**Cause**: Insufficient permissions or directory doesn't exist
**Solution**:
1. Choose a directory you have write access to
2. Create the directory manually if needed
3. On Linux/macOS, check directory permissions

#### Main class not detected
**Cause**: JAR doesn't have proper MANIFEST.MF or multiple main classes
**Solution**:
1. Manually enter the main class name
2. Check JAR's MANIFEST.MF file
3. Verify the main class exists and is public

### Getting Help
1. **Console output**: Check for detailed error messages
2. **Setup guide**: Verify all tools are properly installed
3. **Export logs**: Save console output for troubleshooting
4. **Reset application**: Use "New Configuration" to start fresh

---

## Tips and Best Practices

### Packaging Best Practices
1. **Test your JAR first**: Ensure it runs correctly with `java -jar yourapp.jar`
2. **Use appropriate icons**: Follow platform guidelines for icon sizes and formats
3. **Keep descriptions concise**: Avoid very long application descriptions
4. **Version consistently**: Use semantic versioning (e.g., 1.0.0, 2.1.3)
5. **Test on target platform**: Package and test on the intended operating system

### Performance Optimization
1. **Use JLink for smaller packages**: Enable JLink to reduce distribution size
2. **Optimize JVM arguments**: Set appropriate heap sizes for your application
3. **Choose the right format**: APP_IMAGE for development, installers for distribution
4. **Minimize modules**: Only select required modules in JLink configuration

### Configuration Management
1. **Save configurations frequently**: Especially for complex setups
2. **Use descriptive names**: Make configuration files easy to identify
3. **Create presets for common scenarios**: Speed up repetitive packaging tasks
4. **Version your configurations**: Keep old configurations as backups

### Development Workflow
1. **Develop → Test → Analyze → Package**: Follow this sequence
2. **Use console output**: Monitor for warnings and errors
3. **Iterate quickly**: Use APP_IMAGE format for faster testing
4. **Final packaging**: Use installer formats for release builds

### Cross-Platform Considerations
1. **Path separators**: Use forward slashes in paths when possible
2. **File permissions**: Consider executable permissions on Linux/macOS
3. **Icon formats**: Use platform-appropriate icon formats
4. **Testing**: Test packages on actual target platforms

---

## Advanced Features

### Batch Processing
While not directly supported in the GUI, you can:
1. Save configurations for different variants
2. Use the JSON configuration files programmatically
3. Script the packaging process for CI/CD

### Integration with Build Tools
1. **Maven/Gradle**: Use Packaroo configurations as templates
2. **CI/CD**: Export configurations for automated builds
3. **Version management**: Include configurations in version control

### Customization
1. **Themes**: Switch between light and dark themes
2. **Console preferences**: Export logs for external analysis
3. **Module customization**: Add custom modules for specialized applications

---

## Appendix

### Supported File Formats

**Input JAR Files:**
- Standard JAR files (.jar)
- Executable JAR files with MANIFEST.MF
- Spring Boot executable JARs
- Fat/Uber JARs with dependencies

**Icon Formats:**
- PNG (recommended for all platforms)
- ICO (Windows native)
- JPG/JPEG (basic support)
- GIF (basic support)

**Output Formats by Platform:**

| Platform | APP_IMAGE | EXE | MSI | DMG | PKG | DEB | RPM |
|----------|-----------|-----|-----|-----|-----|-----|-----|
| Windows  | ✅        | ✅  | ✅  | ❌  | ❌  | ❌  | ❌  |
| macOS    | ✅        | ❌  | ❌  | ✅  | ✅  | ❌  | ❌  |
| Linux    | ✅        | ❌  | ❌  | ❌  | ❌  | ✅  | ✅  |

### Version History
- **1.0.0**: Initial release with core packaging functionality
- **1.1.0**: Added dark theme and structured logging
- **1.2.0**: Enhanced setup guide and preset management
- **Current**: All features documented in this manual

---

*This manual covers Packaroo Desktop v1.0.0. For the latest updates and additional resources, visit the project repository.*
