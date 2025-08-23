# Packaroo

A modern Flutter desktop application for packaging Java applications with a sleek, user-friendly interface.

## Overview

Packaroo is a powerful desktop tool that simplifies the process of packaging Java applications using `jpackage` and `jlink`. Built with Flutter and Material Design 3, it provides an intuitive interface for managing packaging projects, monitoring builds, and configuring application settings.

## Features

### 🎯 Project Management
- Create and manage multiple packaging projects
- **Persistent project ordering** - manually arrange projects by dragging or using context menu
- **Automatic order saving** - project order is preserved between app sessions  
- Import/export project configurations
- Project templates for quick setup
- Duplicate existing projects

### 🔧 Build System
- Real-time build monitoring with progress tracking
- Support for both `jpackage` and `jlink`
- Configurable JVM options and application arguments
- Build history and logging

### 🎨 Modern Interface
- Material Design 3 with adaptive theming
- Light/dark mode support
- Responsive desktop layout
- Intuitive navigation and workflow

### ⚙️ Advanced Configuration
- JDK discovery and validation
- Custom module paths and dependencies
- Icon and metadata configuration
- Package type selection (exe, msi, deb, rpm, dmg, pkg)

## Screenshots

*Screenshots will be added once the UI is complete*

## Requirements

- Flutter 3.5.0 or higher
- Java Development Kit (JDK) 14 or higher
- Windows, macOS, or Linux desktop environment

## Installation

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/damoiskii/Packaroo.git
   cd Packaroo/desktop/flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   dart run build_runner build
   ```

3. **Run the application:**
   ```bash
   flutter run -d windows  # or -d macos, -d linux
   ```

### Building for Production

1. **Build for your platform:**
   ```bash
   # Windows
   flutter build windows --release
   
   # macOS
   flutter build macos --release
   
   # Linux
   flutter build linux --release
   ```

2. **Find the built application in:**
   - Windows: `build/windows/x64/runner/Release/`
   - macOS: `build/macos/Build/Products/Release/`
   - Linux: `build/linux/x64/release/bundle/`

## Usage

### Creating Your First Project

1. **Launch Packaroo** and click "New Project"
2. **Configure basic settings:**
   - Project name and description
   - JAR file location
   - Main class name
   - Output directory

3. **Set application metadata:**
   - Application name and version
   - Vendor and copyright information
   - Application icon (optional)

4. **Choose packaging options:**
   - Package type (app-image, exe, msi, etc.)
   - JVM options and arguments
   - JLink optimization settings

5. **Build your package** by clicking the "Build" button

### Advanced Features

- **Project Ordering**: 
  - Drag and drop projects to reorder them in the project list
  - Use the context menu (⋮) to move projects to top or bottom
  - Project order is automatically saved and restored when the app is reopened
  - Search functionality temporarily hides ordering features

- **JLink Integration**: Enable JLink to create optimized runtime images
- **Module Management**: Configure custom modules and dependencies
- **Build Monitoring**: Track build progress and view detailed logs
- **Settings**: Configure default JDK paths and preferences

## Project Structure

```
lib/
├── main.dart                 # Application entry point
├── models/                   # Data models and Hive adapters
│   ├── packaroo_project.dart
│   ├── build_progress.dart
│   └── app_models.dart
├── providers/                # State management
│   ├── project_provider.dart
│   ├── build_provider.dart
│   └── settings_provider.dart
├── services/                 # Business logic
│   ├── package_service.dart
│   └── storage_service.dart
├── screens/                  # UI screens
│   └── home_screen.dart
├── widgets/                  # Reusable UI components
└── utils/                    # Utility functions
```

## Dependencies

### Core Dependencies
- **flutter**: UI framework
- **provider**: State management
- **hive**: Local database
- **window_manager**: Desktop window management

### UI Dependencies
- **material_symbols_icons**: Modern Material icons
- **animated_text_kit**: Text animations
- **lottie**: Animation support

### Functionality Dependencies
- **file_picker**: File selection dialogs
- **path_provider**: System paths
- **process_run**: Command execution
- **url_launcher**: External links

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with [Flutter](https://flutter.dev/)
- Icons from [Material Symbols](https://fonts.google.com/icons)
- Inspired by the need for better Java packaging tools

## Support

If you encounter any issues or have questions:

1. Check the [Issues](https://github.com/damoiskii/Packaroo/issues) page
2. Create a new issue with detailed information
3. Join the discussion in our community

---

**Made with ❤️ for the Java developer community**
