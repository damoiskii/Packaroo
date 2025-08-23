#!/bin/bash

# Script to help set window icon on Linux
# This script tries multiple approaches to set the window icon

ICON_PATH="assets/icons/icon.png"
APP_NAME="packaroo"

echo "Setting up window icon for Linux..."

# Method 1: Install icon to system directories
if [ -f "$ICON_PATH" ]; then
    echo "Installing icon to system directories..."
    
    # Install to user icon directory
    mkdir -p ~/.local/share/icons
    cp "$ICON_PATH" ~/.local/share/icons/packaroo.png
    
    # Install to pixmaps (for older systems)
    mkdir -p ~/.local/share/pixmaps
    cp "$ICON_PATH" ~/.local/share/pixmaps/packaroo.png
    
    echo "Icon installed to user directories"
fi

# Method 2: Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    echo "Updating GTK icon cache..."
    gtk-update-icon-cache ~/.local/share/icons/ 2>/dev/null || true
fi

if command -v update-icon-caches &> /dev/null; then
    echo "Updating system icon cache..."
    update-icon-caches ~/.local/share/icons/ 2>/dev/null || true
fi

# Method 3: Create desktop entry for proper integration
DESKTOP_FILE="$HOME/.local/share/applications/packaroo.desktop"
echo "Creating desktop entry..."
cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Name=Packaroo
Comment=A modern Java application packaging tool
GenericName=Java Package Manager
Exec=packaroo
Icon=packaroo
StartupNotify=true
NoDisplay=false
Type=Application
Categories=Development;
Keywords=java;packaging;jpackage;jlink;development;
StartupWMClass=packaroo
EOF

# Method 4: Update desktop database
if command -v update-desktop-database &> /dev/null; then
    echo "Updating desktop database..."
    update-desktop-database ~/.local/share/applications/
fi

echo "Linux icon setup complete!"
echo ""
echo "Tips for window title bar icons:"
echo "1. Some desktop environments don't show icons in title bars by default"
echo "2. Try installing the .deb package for proper system integration"
echo "3. The icon should appear in application launchers and taskbars"
echo "4. For title bar icons, your desktop environment settings may need adjustment"
