# 📦 Packaroo Desktop v1.0.0 - Linux Release

### 🚀 What's New

**Packaroo Desktop** is a modern JavaFX application that simplifies the process of packaging Java applications into native installers using Java's `jpackage` and `jlink` tools. This initial Linux release brings powerful packaging capabilities with an intuitive graphical interface.

### ✨ Key Features

#### 🎯 Core Functionality
- **JAR Analysis**: Automatically analyze JAR files using `jdeps` to identify required Java modules and main classes
- **Smart Auto-Population**: Extract application metadata from JAR filenames and manifest files
- **Custom Runtime Creation**: Generate minimal Java runtime images with `jlink` for smaller distributions
- **Native Linux Packaging**: Create platform-specific packages (DEB, RPM, APP_IMAGE)
- **Cross-Platform Support**: Target multiple platforms from Linux (Windows, macOS, Linux)

#### 🎨 Modern User Interface
- **JavaFX Interface**: Clean, responsive, and modern desktop application
- **Dark/Light Themes**: Toggle between light and dark UI themes
- **Animated Splash Screen**: Professional loading experience with progress indicators
- **Structured Console**: Real-time output with categorized, color-coded logging

#### ⚙️ Advanced Configuration
- **Configuration Management**: Save and load complete packaging configurations as JSON files
- **Preset System**: Create reusable configuration templates for common scenarios
- **Module Management**: Visual interface for selecting required Java modules
- **Advanced Options**: Custom JVM arguments and application parameters
- **Input Validation**: Comprehensive validation with helpful error messages

### 🐧 Linux-Specific Features

- **Native Package Formats**:
  - **APP_IMAGE**: Portable application directory
  - **DEB**: Debian/Ubuntu package format
  - **RPM**: Red Hat/Fedora package format
- **Linux Distribution Support**: Ubuntu 18.04+, CentOS 7+, Fedora, openSUSE
- **Desktop Integration**: Proper menu entries and application icons

### 📋 System Requirements

- **Java Runtime**: Java 17 or higher (for running Packaroo)
- **Development Tools**: JDK 14+ (for jpackage functionality)
- **Operating System**: Linux (Ubuntu 18.04+, CentOS 7+, or compatible)
- **Required Tools in PATH**:
  - `java` - Java runtime
  - `jdeps` - Dependency analysis (included with JDK)
  - `jlink` - Custom runtime creation (included with JDK)
  - `jpackage` - Native packaging (JDK 14+)

### 🛠️ Installation & Usage

#### Quick Start
```bash
# Clone the repository
git clone https://github.com/damoiskii/Packaroo.git
cd Packaroo/desktop

# Run the application
./mvnw javafx:run
```

#### Using the JAR File
```bash
java -jar packaroo-desktop-1.0.0.jar
```

### 📚 Documentation

This release includes a comprehensive **586-line User Manual** covering:
- Complete interface overview and workflow
- Step-by-step packaging instructions
- Advanced configuration options
- Linux-specific setup guide
- Troubleshooting and best practices
- Platform-specific considerations

### 🔧 Setup Requirements

Before using Packaroo, ensure you have the required tools installed:

```bash
# Verify Java installation
java --version
javac --version

# Verify packaging tools
jdeps --version
jlink --version
jpackage --version
```

### 💡 Getting Started

1. **Launch Packaroo**: Run the application using Maven or the JAR file
2. **Select JAR File**: Choose your application's JAR file
3. **Auto-Configuration**: Watch as Packaroo automatically populates fields
4. **Analyze Dependencies**: Use the built-in analysis to detect required modules
5. **Configure Packaging**: Set target platform and output format
6. **Package Application**: Create your native Linux package

### 🎯 Use Cases

- **Desktop Application Distribution**: Create professional installers for JavaFX/Swing applications
- **Spring Boot Packaging**: Package Spring Boot applications as native Linux packages
- **Cross-Platform Development**: Develop on Linux, target multiple platforms
- **CI/CD Integration**: Use saved configurations for automated packaging
- **Development Testing**: Quick APP_IMAGE creation for testing

### 🚀 What's Next

Future releases will include:
- Enhanced cross-platform packaging
- Batch processing capabilities
- CI/CD integration tools
- Additional Linux distribution support
- Performance optimizations

### 📞 Support

- **Setup Guide**: Built-in comprehensive setup instructions
- **User Manual**: Complete 586-line documentation included
- **Console Logging**: Detailed structured output for troubleshooting
- **GitHub Issues**: Report bugs and request features

### 🏷️ Technical Details

- **Framework**: Spring Boot 3.5.3 + JavaFX 21
- **Java Version**: Built with Java 17
- **Build Tool**: Maven
- **Architecture**: Desktop application with JavaFX UI
- **Configuration**: JSON-based configuration management

---

**Download**: Get the `packaroo-desktop-1.0.0.jar` from the releases section and start packaging your Java applications with ease!

**Note**: This is the initial Linux release. Windows and macOS native packages will be available in future releases.
