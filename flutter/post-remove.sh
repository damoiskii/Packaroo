#!/bin/bash
# Post-removal script

# Remove symlink
rm -f /usr/bin/packaroo

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications
fi

echo "Packaroo removed successfully."
