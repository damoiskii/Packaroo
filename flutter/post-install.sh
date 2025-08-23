#!/bin/bash
# Post-installation script

# Create symlink to make the app available in PATH
ln -sf /usr/lib/packaroo/packaroo /usr/bin/packaroo

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache /usr/share/pixmaps
fi

echo "Packaroo installed successfully!"
echo "You can now run 'packaroo' from the command line or find it in your applications menu."
