#!/bin/bash

# Script to create a .deb package using jpackage
# Make sure you have built the project first with: ./mvnw clean package -DskipTests

set -e

echo "Creating .deb package for Packaroo..."

# Check if jpackage is available
if ! command -v jpackage &> /dev/null; then
    echo "Error: jpackage command not found"
    echo "Make sure you have JDK 14+ installed and jpackage is in your PATH"
    exit 1
fi

# Create output directory
mkdir -p dist

# Run jpackage
jpackage \
  --input target \
  --name Packaroo \
  --main-jar packaroo-desktop-1.0.0-exec.jar \
  --main-class org.springframework.boot.loader.launch.JarLauncher \
  --type deb \
  --dest dist \
  --app-version 1.0.0 \
  --vendor "DevDam" \
  --description "Cross-platform desktop application for Java packaging with jpackage and jlink" \
  --linux-shortcut \
  --linux-menu-group "Development"

echo "✅ .deb package created successfully in dist/ directory"
echo "Install with: sudo dpkg -i dist/packaroo_1.0.0-1_amd64.deb"
