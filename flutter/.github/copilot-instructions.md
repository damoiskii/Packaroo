# Copilot Instructions for Packaroo

<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

## Project Overview

Packaroo is a modern Flutter desktop application for packaging Java applications using `jpackage` and `jlink`. It provides a user-friendly interface for managing Java application packaging projects with modern Material Design 3 UI.

## Key Features

- **Project Management**: Create, edit, and manage multiple packaging projects
- **Build System**: Real-time build monitoring with progress tracking
- **Modern UI**: Material Design 3 with light/dark theme support
- **Cross-Platform**: Windows, macOS, and Linux desktop support
- **Storage**: Local data persistence using Hive database
- **Settings**: Configurable preferences and project defaults

## Architecture

- **State Management**: Provider pattern for reactive state management
- **Models**: Hive-based data models with JSON serialization
- **Services**: Business logic separation for packaging and storage
- **Screens**: Feature-based UI organization
- **Widgets**: Reusable UI components
- **Providers**: State management controllers

## Code Style Guidelines

1. **Dart/Flutter Best Practices**:
   - Use const constructors where possible
   - Follow Material Design 3 principles
   - Implement proper error handling
   - Use meaningful variable and function names

2. **State Management**:
   - Use Provider for dependency injection
   - Keep business logic in providers
   - Use Consumer/Selector for optimal rebuilds

3. **UI/UX**:
   - Follow Material Design 3 guidelines
   - Ensure responsive design for desktop
   - Provide proper loading states and error handling
   - Use semantic icons from material_symbols_icons

4. **File Organization**:
   - Group related functionality in appropriate folders
   - Use barrel exports for clean imports
   - Keep models, services, and UI separated

## Dependencies

Key packages used:
- `provider`: State management
- `hive`: Local database
- `window_manager`: Desktop window management
- `material_symbols_icons`: Modern Material icons
- `file_picker`: File selection dialogs
- `process_run`: Command execution

## Development Notes

- This is a desktop-first application targeting Windows, macOS, and Linux
- The app manages Java packaging workflows using jpackage and jlink
- Focus on user experience with clear visual feedback for build processes
- Maintain compatibility with various Java versions and platforms
- Ensure proper error handling for file system operations and process execution
