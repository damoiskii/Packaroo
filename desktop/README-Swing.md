# Packaroo Desktop - Swing Version

A modern Java Swing application for packaging Java applications using jpackage and jlink tools.

## What Was Converted

This project has been successfully converted from JavaFX to Java Swing while maintaining Spring Boot integration:

### Dependencies Converted
- ✅ **JavaFX** → **Java Swing**
- ✅ **ControlsFX** → **FlatLaf** (Modern Look and Feel)
- ✅ **JavaFX FXML** → **Programmatic Swing UI**
- ✅ **JavaFX WebView** → **Swing JTextArea with formatted content**

### Architecture Changes
- ✅ **JavaFX Application** → **Standard Java Application with Swing**
- ✅ **FXML Controllers** → **Swing Panels and Components**
- ✅ **JavaFX Platform.runLater()** → **SwingUtilities.invokeLater()**
- ✅ **JavaFX Scene Management** → **Swing JFrame and JDialog**

### UI Components Converted
- ✅ **MainController** → **MainFrame** with tabbed interface
- ✅ **SplashController** → **SplashScreen** with progress animation
- ✅ **SetupGuideController** → **SetupGuideDialog** with scrollable text
- ✅ **File Selection Controls** → **FileSelectionPanel**
- ✅ **Package Configuration** → **PackageConfigPanel**
- ✅ **Advanced Options** → **AdvancedOptionsPanel**
- ✅ **Console Output** → **ConsolePanel** with color coding

### Features Preserved
- ✅ **Spring Boot Integration** - Full dependency injection support
- ✅ **Configuration Management** - Save/load JSON configurations
- ✅ **Theme Support** - Light/Dark theme switching
- ✅ **Logging System** - Comprehensive console logging
- ✅ **Progress Tracking** - Visual progress bars and status updates
- ✅ **File Dialogs** - Native file choosers for JAR, icon, and output selection
- ✅ **Menu System** - Full menu bar with keyboard shortcuts
- ✅ **Window State Persistence** - Remembers window size, position, and theme

## Key Improvements

### Better Cross-Platform Support
- **FlatLaf** provides consistent modern appearance across all platforms
- Native Swing components integrate better with system themes
- Better font rendering and scaling support

### Enhanced User Experience
- Faster startup time compared to JavaFX
- Lower memory footprint
- Better integration with system accessibility features
- Native file dialogs and system integration

### Improved Maintainability
- Programmatic UI creation (no FXML dependencies)
- Standard Swing patterns familiar to Java developers
- Simplified build process (no JavaFX module dependencies)

## Project Structure

```
src/main/java/com/devdam/desktop/
├── DesktopApplication.java          # Main application entry point
├── model/                           # Data models (unchanged)
│   ├── PackageConfiguration.java
│   ├── PackagingResult.java
│   └── ...
├── service/                         # Business logic (updated for Swing)
│   ├── ConfigurationService.java
│   ├── ConsoleLoggerService.java    # Updated for Swing JTextArea
│   ├── PackagingService.java
│   └── ViewManager.java             # Simplified for Swing
└── ui/                              # Swing UI components (new)
    ├── MainFrame.java               # Main application window
    ├── SplashScreen.java            # Startup splash screen
    ├── SetupGuideDialog.java        # Setup instructions dialog
    └── panels/                      # Reusable UI panels
        ├── FileSelectionPanel.java
        ├── PackageConfigPanel.java
        ├── AdvancedOptionsPanel.java
        └── ConsolePanel.java
```

## Running the Application

### Prerequisites
- JDK 17 or higher
- Maven 3.6+

### Build and Run
```bash
# Compile the project
./mvnw compile

# Run the application
./mvnw spring-boot:run

# Create executable JAR
./mvnw package
```

### Run the packaged JAR
```bash
java -jar target/packaroo-desktop-1.0.0-exec.jar
```

## Features

- **File Selection**: Choose JAR files, icons, and output directories
- **Package Configuration**: Set application name, version, vendor, etc.
- **Advanced Options**: JLink runtime creation, JVM/app arguments
- **Console Logging**: Real-time feedback with different log levels
- **Theme Support**: Light and dark themes
- **Configuration Management**: Save and load packaging configurations
- **Setup Guide**: Comprehensive installation instructions

## Technology Stack

- **Java 17+** - Core language
- **Spring Boot 3.5** - Application framework and dependency injection
- **Swing** - Native Java GUI framework
- **FlatLaf 3.2** - Modern Look and Feel
- **Lombok** - Code generation
- **Jackson** - JSON serialization
- **Maven** - Build tool

## Development Notes

### Why Swing Over JavaFX?
1. **Better Integration**: Native Java component, no external dependencies
2. **Broader Compatibility**: Works on more systems without additional setup
3. **Performance**: Lower memory usage and faster startup
4. **Maintenance**: Simpler deployment and fewer moving parts
5. **Enterprise Ready**: Better support in corporate environments

### Key Design Decisions
- **Component-based Architecture**: Each UI section is a separate panel for modularity
- **Event-Driven Design**: Clean separation between UI and business logic
- **Theme Support**: Full dark/light theme switching with persistence
- **Spring Integration**: Leverages dependency injection for clean architecture

## Future Enhancements

- JAR dependency analysis implementation
- Real packaging service integration
- Custom module detection
- Enhanced progress tracking
- Plugin system for custom packaging workflows

---

**Note**: This conversion maintains full functional compatibility with the original JavaFX version while providing better cross-platform support and improved user experience through native Swing components.
