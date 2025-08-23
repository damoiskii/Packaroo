#!/bin/bash

# Install Packaroo icon and desktop file for Linux

# Create icon directory if it doesn't exist
mkdir -p ~/.local/share/icons

# Copy the app icon
cp "$(dirname "$0")/assets/icons/icon.png" ~/.local/share/icons/packaroo.png

# Create applications directory if it doesn't exist  
mkdir -p ~/.local/share/applications

# Create desktop file
cat > ~/.local/share/applications/packaroo.desktop << EOF
[Desktop Entry]
Name=Packaroo
Comment=A modern Java application packaging tool
GenericName=Java Package Manager
Exec=$(pwd)/build/linux/x64/release/bundle/packaroo
Icon=$HOME/.local/share/icons/packaroo.png
StartupNotify=true
NoDisplay=false
Type=Application
Categories=Development;
Keywords=java;packaging;jpackage;jlink;development;
EOF

# Make desktop file executable
chmod +x ~/.local/share/applications/packaroo.desktop

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database ~/.local/share/applications
fi

echo "Packaroo icon and desktop file installed successfully!"
echo "You should now see Packaroo in your application menu."
