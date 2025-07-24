# Packaroo - Java Application Packager

Packaroo is a modern, cross-platform desktop application built with JavaFX and Spring Boot that simplifies the process of packaging Java applications using `jpackage` and `jlink`.

## Features

### 🎯 Core Functionality
- **JAR Analysis**: Automatically analyze JAR files using `jdeps` to identify required Java modules
- **Custom Runtime Creation**: Generate minimal Java runtime images with `jlink`
- **Native Packaging**: Create platform-specific installers with `jpackage`
- **Multi-Platform Support**: Target Windows, macOS, and Linux from any platform

### 🎨 Modern UI
- **JavaFX Interface**: Clean, responsive, and modern user interface
- **Dark/Light Themes**: Support for both dark and light UI themes
- **Smooth Animations**: Transition effects and visual feedback
- **Splash Screen**: Animated loading screen with progress indicator

### ⚙️ Advanced Features
- **Configuration Presets**: Save and load packaging configurations
- **Real-time Console**: Live output from packaging tools with export capability
- **Module Management**: Visual interface for selecting required Java modules
- **Validation**: Input validation and helpful error messages

## Requirements

### System Requirements
- **Java 17 or higher** with JDK (required for `jlink` and `jpackage`)
- **Operating System**: Windows 10+, macOS 10.14+, or Linux (Ubuntu 18.04+, CentOS 7+)

### Required Tools
These tools must be available in your system PATH:
- `java` - Java runtime
- `jdeps` - Dependency analysis tool (included with JDK)
- `jlink` - Custom runtime image creation tool (included with JDK)
- `jpackage` - Native package creation tool (JDK 14+)

## Installation

### Option 1: Run from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/damoiskii/Packaroo.git
   cd Packaroo/desktop
   ```

2. Build and run:
   ```bash
   ./mvnw javafx:run
   ```

### Option 2: Build Executable JAR
1. Build the project:
   ```bash
   ./mvnw clean package
   ```

2. Run the generated JAR:
   ```bash
   java -jar target/packaroo-desktop-1.0.0.jar
   ```

## Usage

### Basic Workflow

1. **Select JAR File**: Choose the Java application JAR file you want to package
2. **Configure Application**: Set application name, version, main class, and other metadata
3. **Analyze Dependencies**: Click "Analyze JAR" to automatically detect required modules
4. **Choose Platform & Format**: Select target platform and installer type
5. **Configure Runtime** (Optional): Enable JLink to create a minimal custom runtime
6. **Package Application**: Click "Package App" to create the native installer

### Advanced Configuration

#### JLink Options
- Enable JLink to create a custom runtime with only required modules
- Manually select or add custom modules
- Reduces distribution size significantly

#### Platform Options
- **Windows**: `.exe` executable or `.msi` installer
- **macOS**: `.pkg` installer or `.dmg` disk image
- **Linux**: `.deb` package or `.rpm` package

#### Application Metadata
- Application name and version
- Vendor information
- Description and copyright
- Custom application icon
- JVM and application arguments

### Configuration Presets
Save frequently used configurations as presets for quick reuse:
1. Configure your application settings
2. Enter a preset name
3. Click "Save Preset"
4. Load presets from the dropdown menu

## Project Structure

```
src/
├── main/
│   ├── java/com/devdam/desktop/
│   │   ├── PackarooApplication.java       # Main application class
│   │   ├── controller/                    # JavaFX controllers
│   │   │   ├── MainController.java        # Main window controller
│   │   │   └── SplashController.java      # Splash screen controller
│   │   ├── model/                         # Data models
│   │   │   ├── PackageConfiguration.java  # Configuration model
│   │   │   ├── PackagingResult.java       # Result model
│   │   │   └── DependencyAnalysis.java    # Analysis result model
│   │   └── service/                       # Business logic services
│   │       ├── DependencyAnalysisService.java # JAR analysis
│   │       ├── PackagingService.java      # jpackage/jlink operations
│   │       └── ConfigurationService.java # Preset management
│   └── resources/
│       ├── fxml/                          # JavaFX FXML layouts
│       │   ├── main.fxml                  # Main window layout
│       │   └── splash.fxml                # Splash screen layout
│       ├── css/                           # Stylesheets
│       │   └── styles.css                 # Application styles
│       ├── images/                        # Application icons
│       └── application.properties         # Spring Boot configuration
└── test/                                  # Unit tests
```

## Architecture

Packaroo follows the Model-View-Controller (MVC) pattern:

- **Model**: Data classes representing configuration, results, and analysis
- **View**: FXML layouts and CSS styling for the user interface
- **Controller**: JavaFX controllers handling user interactions
- **Service Layer**: Spring Boot services managing business logic

### Key Technologies
- **JavaFX**: Modern Java UI framework for desktop applications
- **Spring Boot**: Dependency injection and application configuration
- **ControlsFX**: Enhanced UI controls and components
- **Lombok**: Reducing boilerplate code with annotations
- **Jackson**: JSON serialization for configuration presets

## Troubleshooting

### Common Issues

#### "jpackage not found"
- Ensure you're using JDK 14 or higher
- Verify `jpackage` is in your system PATH
- On some Linux distributions, you may need to install additional packages

#### "jlink failed"
- Check that all required modules are available
- Some third-party libraries may not be compatible with jlink
- Try disabling jlink to create a traditional package

#### "Invalid module name"
- Module names must follow Java module naming conventions
- Use `jdeps` output to verify correct module names

### Getting Help
- Check the console output for detailed error messages
- Export logs using the "Export Logs" button for debugging
- Ensure all required tools are properly installed and accessible

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and add tests
4. Commit your changes: `git commit -am 'Add new feature'`
5. Push to the branch: `git push origin feature-name`
6. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Oracle for JavaFX and the JDK packaging tools
- Spring team for the excellent Spring Boot framework
- ControlsFX team for enhanced JavaFX controls
- The Java community for continuous support and feedback
