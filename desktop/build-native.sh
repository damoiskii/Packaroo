#!/bin/bash

# Build script for Packaroo Desktop using jpackage (without jlink due to Spring Boot compatibility)

echo "Building Packaroo Desktop Application..."

# Clean previous builds
echo "Cleaning previous builds..."
mvn clean

# Compile and package
echo "Compiling and packaging..."
mvn package -DskipTests

# Create native installer with jpackage (includes bundled JRE)
echo "Creating native installer with jpackage..."
mvn jpackage:jpackage

echo "Build complete! Check target/installer/ for the native installer."

# Note: This approach bundles a full JRE with JavaFX modules
echo "Note: The installer includes a bundled JRE with JavaFX support."
