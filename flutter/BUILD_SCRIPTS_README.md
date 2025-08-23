# Packaroo Build Scripts

This directory contains platform-specific build scripts for creating distributable packages of the Packaroo Flutter application.

## Available Scripts

### Linux - `build-deb.sh`
Creates a Debian package (.deb) for Ubuntu and other Debian-based distributions.

**Requirements:**
- Flutter SDK with Linux desktop support
- `dpkg-deb` (usually pre-installed on Ubuntu/Debian)
- Optional: `lintian` for package validation

**Usage:**
```bash
./build-deb.sh
```

**Output:**
- `debian-package/packaroo-2.0.0.deb` - Installable Debian package

### Windows - `build-windows.ps1` (PowerShell)
Creates Windows packages including portable ZIP and NSIS installer.

**Requirements:**
- Flutter SDK with Windows desktop support
- PowerShell 5.0+ (Windows 10/11)
- Optional: NSIS for creating installers

**Usage:**
```powershell
# Basic build
.\build-windows.ps1

# With custom version and architecture
.\build-windows.ps1 -Version "2.1.0" -Architecture "x64"

# Show help
.\build-windows.ps1 -Help
```

**Supported Architectures:** x64, x86, arm64

**Output:**
- `windows-package/packaroo-VERSION-windows-ARCH/` - Portable application folder
- `windows-package/packaroo-VERSION-windows-ARCH-portable.zip` - ZIP archive
- `windows-package/packaroo-VERSION-windows-ARCH-setup.exe` - NSIS installer (if NSIS available)

### Windows - `build-windows.bat` (Batch)
Simplified Windows build script for environments with PowerShell restrictions.

**Requirements:**
- Flutter SDK with Windows desktop support
- Windows Command Prompt

**Usage:**
```cmd
build-windows.bat
```

**Output:**
- `windows-package/packaroo-VERSION-windows-ARCH/` - Portable application folder
- `windows-package/packaroo-VERSION-windows-ARCH-portable.zip` - ZIP archive (if PowerShell available)

### macOS - `build-macos.sh`
Creates macOS app bundles and DMG disk images with optional code signing and notarization.

**Requirements:**
- Flutter SDK with macOS desktop support
- Xcode Command Line Tools
- macOS 10.14 or later

**Optional for Distribution:**
- Apple Developer certificate (for code signing)
- Apple ID with app-specific password (for notarization)

**Usage:**
```bash
# Basic build
./build-macos.sh

# With custom version and architecture
./build-macos.sh --version "2.1.0" --arch "arm64"

# Build with code signing
./build-macos.sh --sign

# Build with code signing and notarization
export APPLE_ID="your.email@example.com"
export APPLE_ID_PASSWORD="your-app-specific-password"
export APPLE_TEAM_ID="YOUR_TEAM_ID"  # Optional
./build-macos.sh --sign --notarize

# Show help
./build-macos.sh --help
```

**Supported Architectures:** x64, arm64

**Output:**
- `macos-package/Packaroo-VERSION-macos-ARCH/Packaroo.app` - Application bundle
- `macos-package/Packaroo-VERSION-macos-ARCH.dmg` - Disk image for distribution

## Platform-Specific Notes

### Linux (Debian/Ubuntu)
- The .deb package will install to `/usr/lib/packaroo/` with a launcher in `/usr/bin/packaroo`
- Desktop entry is created for application menu integration
- Package can be installed with: `sudo dpkg -i packaroo-VERSION.deb`

### Windows
- **PowerShell Script**: More feature-rich with NSIS installer support
- **Batch Script**: Simpler, works without PowerShell execution policy changes
- The portable version can be run directly without installation
- NSIS installer creates proper Windows integration (Start Menu, uninstaller, etc.)

### macOS
- Creates proper `.app` bundle with correct metadata
- DMG includes drag-to-Applications installation
- Code signing prevents "unidentified developer" warnings
- Notarization required for distribution outside Mac App Store on macOS 10.15+

## Code Signing & Notarization (macOS)

### Setting up Code Signing
1. Join the Apple Developer Program
2. Create certificates in Xcode or Apple Developer portal
3. Install certificates in Keychain Access

### Setting up Notarization
1. Generate an app-specific password:
   - Go to appleid.apple.com
   - Sign in and go to Security section
   - Generate app-specific password
2. Set environment variables:
   ```bash
   export APPLE_ID="your.email@example.com"
   export APPLE_ID_PASSWORD="your-app-specific-password"
   export APPLE_TEAM_ID="YOUR_TEAM_ID"  # Optional but recommended
   ```

## Troubleshooting

### Common Issues

**Flutter build fails:**
- Ensure Flutter is properly installed and in PATH
- Run `flutter doctor` to check for issues
- Ensure desktop support is enabled: `flutter config --enable-<platform>-desktop`

**Windows: PowerShell execution policy:**
- Run as Administrator: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or use the batch file version instead

**macOS: Code signing fails:**
- Check available certificates: `security find-identity -v -p codesigning`
- Ensure Xcode Command Line Tools are installed: `xcode-select --install`

**macOS: Notarization fails:**
- Verify Apple ID credentials are correct
- Check that app-specific password is valid
- Ensure network connectivity for Apple's notarization service

### Package Validation

**Linux:**
```bash
# Check package contents
dpkg -c packaroo-VERSION.deb

# Install and test
sudo dpkg -i packaroo-VERSION.deb
packaroo  # Should launch the application
```

**Windows:**
```powershell
# Test the portable version
cd windows-package/packaroo-VERSION-windows-ARCH
./packaroo.exe
```

**macOS:**
```bash
# Verify app bundle
spctl --assess --verbose macos-package/Packaroo-VERSION-macos-ARCH/Packaroo.app

# Test installation from DMG
open macos-package/Packaroo-VERSION-macos-ARCH.dmg
```

## Customization

All scripts can be modified to change:
- Application metadata (name, version, description)
- Package structure and file organization
- Installation paths and integration
- Icon and branding elements

Key configuration variables are defined at the top of each script for easy modification.
