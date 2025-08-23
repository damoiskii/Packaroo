#!/bin/bash

# Packaroo macOS Package Builder
# This script builds a macOS app bundle and DMG from your Flutter macOS build

set -e

# Configuration
APP_NAME="Packaroo"
APP_ID="com.damoiskii.packaroo"
VERSION="2.0.0"
MAINTAINER="Damoiskii"
DESCRIPTION="A modern Java application packaging tool"
HOMEPAGE="https://github.com/damoiskii/Packaroo"
BUNDLE_ID="com.damoiskii.packaroo"

# Parse command line arguments
ARCH="x64"
SIGN_APP=false
NOTARIZE=false
HELP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            shift 2
            ;;
        --arch)
            ARCH="$2"
            shift 2
            ;;
        --sign)
            SIGN_APP=true
            shift
            ;;
        --notarize)
            NOTARIZE=true
            SIGN_APP=true
            shift
            ;;
        --help|-h)
            HELP=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            HELP=true
            shift
            ;;
    esac
done

if [ "$HELP" = true ]; then
    cat << EOF
Packaroo macOS Build Script

Usage: ./build-macos.sh [OPTIONS]

Options:
    --version VERSION    Set the application version (default: 2.0.0)
    --arch ARCH         Set target architecture: x64, arm64 (default: x64)
    --sign              Sign the application (requires developer certificate)
    --notarize          Notarize the application (requires Apple ID and app-specific password)
    --help, -h          Show this help message

Examples:
    ./build-macos.sh
    ./build-macos.sh --version "2.1.0" --arch "arm64"
    ./build-macos.sh --sign --notarize

This script will:
1. Build the Flutter macOS application
2. Create a properly structured .app bundle
3. Generate a DMG disk image for distribution
4. Optionally sign and notarize the application

Requirements:
- Flutter SDK with macOS desktop support
- Xcode Command Line Tools
- For signing: Valid Apple Developer certificate
- For notarization: Apple ID with app-specific password

Environment variables for notarization:
    APPLE_ID: Your Apple ID email
    APPLE_ID_PASSWORD: App-specific password
    APPLE_TEAM_ID: Your team ID (optional)
EOF
    exit 0
fi

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/macos-package"
PKG_DIR="${BUILD_DIR}/${APP_NAME}-${VERSION}-macos-${ARCH}"
FLUTTER_BUILD_DIR="${SCRIPT_DIR}/build/macos/Build/Products/Release"
APP_BUNDLE="${FLUTTER_BUILD_DIR}/${APP_NAME}.app"
FINAL_APP_BUNDLE="${PKG_DIR}/${APP_NAME}.app"

echo "Building Flutter application for macOS (${ARCH})..."
if [ "$ARCH" = "arm64" ]; then
    flutter build macos --release --target-platform darwin-arm64
elif [ "$ARCH" = "x64" ]; then
    flutter build macos --release --target-platform darwin-x64
else
    echo "Error: Unsupported architecture: $ARCH"
    echo "Supported architectures: x64, arm64"
    exit 1
fi

echo "Creating package directory structure..."
rm -rf "${BUILD_DIR}"
mkdir -p "${PKG_DIR}"

echo "Copying application bundle..."
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: Flutter build not found at ${APP_BUNDLE}"
    exit 1
fi

cp -R "${APP_BUNDLE}" "${FINAL_APP_BUNDLE}"

echo "Updating app bundle metadata..."
# Update Info.plist with correct version and bundle ID
INFO_PLIST="${FINAL_APP_BUNDLE}/Contents/Info.plist"
if [ -f "${INFO_PLIST}" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${VERSION}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleVersion string ${VERSION}" "${INFO_PLIST}"
    
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${VERSION}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleShortVersionString string ${VERSION}" "${INFO_PLIST}"
    
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${BUNDLE_ID}" "${INFO_PLIST}" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string ${BUNDLE_ID}" "${INFO_PLIST}"
    
    echo "Updated Info.plist with version ${VERSION} and bundle ID ${BUNDLE_ID}"
fi

# Create application icon if it doesn't exist
ICON_SOURCE="${SCRIPT_DIR}/assets/icons/icon.png"
ICON_DIR="${FINAL_APP_BUNDLE}/Contents/Resources"
ICONSET_DIR="${BUILD_DIR}/AppIcon.iconset"

if [ -f "${ICON_SOURCE}" ]; then
    echo "Creating application icon..."
    mkdir -p "${ICONSET_DIR}"
    
    # Generate different icon sizes
    sips -z 16 16 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_16x16.png" >/dev/null 2>&1
    sips -z 32 32 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_16x16@2x.png" >/dev/null 2>&1
    sips -z 32 32 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_32x32.png" >/dev/null 2>&1
    sips -z 64 64 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_32x32@2x.png" >/dev/null 2>&1
    sips -z 128 128 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_128x128.png" >/dev/null 2>&1
    sips -z 256 256 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_128x128@2x.png" >/dev/null 2>&1
    sips -z 256 256 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_256x256.png" >/dev/null 2>&1
    sips -z 512 512 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_256x256@2x.png" >/dev/null 2>&1
    sips -z 512 512 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_512x512.png" >/dev/null 2>&1
    sips -z 1024 1024 "${ICON_SOURCE}" --out "${ICONSET_DIR}/icon_512x512@2x.png" >/dev/null 2>&1
    
    # Create .icns file
    iconutil -c icns "${ICONSET_DIR}" -o "${ICON_DIR}/AppIcon.icns"
    rm -rf "${ICONSET_DIR}"
    echo "Created application icon"
else
    echo "Warning: Icon not found at ${ICON_SOURCE}"
fi

# Code signing
if [ "$SIGN_APP" = true ]; then
    echo "Attempting to sign the application..."
    
    # Find available signing identities
    SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Developer ID Application" | head -1 | grep -o '"[^"]*"' | tr -d '"')
    
    if [ -z "$SIGN_IDENTITY" ]; then
        echo "Warning: No Developer ID Application certificate found. Trying alternative certificates..."
        SIGN_IDENTITY=$(security find-identity -v -p codesigning | grep "Mac Developer\|Apple Development" | head -1 | grep -o '"[^"]*"' | tr -d '"')
    fi
    
    if [ -n "$SIGN_IDENTITY" ]; then
        echo "Signing with identity: $SIGN_IDENTITY"
        codesign --force --verify --verbose --sign "$SIGN_IDENTITY" "${FINAL_APP_BUNDLE}"
        echo "Application signed successfully"
        
        # Verify signature
        echo "Verifying signature..."
        codesign --verify --verbose=2 "${FINAL_APP_BUNDLE}"
        spctl --assess --verbose=2 "${FINAL_APP_BUNDLE}"
    else
        echo "Warning: No suitable code signing certificate found"
        echo "To sign your app, you need a valid Apple Developer certificate"
        SIGN_APP=false
    fi
fi

echo "Creating README.txt..."
cat > "${PKG_DIR}/README.txt" << EOF
${APP_NAME} v${VERSION}
${DESCRIPTION}

Installation:
1. Copy ${APP_NAME}.app to your Applications folder
2. Launch ${APP_NAME} from Applications or Launchpad

System Requirements:
- macOS 10.14 or later
- ${ARCH} architecture

For more information, visit: ${HOMEPAGE}

Maintainer: ${MAINTAINER}
Version: ${VERSION}
Architecture: ${ARCH}
EOF

echo "Creating DMG disk image..."
DMG_NAME="${APP_NAME}-${VERSION}-macos-${ARCH}.dmg"
DMG_PATH="${BUILD_DIR}/${DMG_NAME}"

# Create temporary DMG
hdiutil create -srcfolder "${PKG_DIR}" -volname "${APP_NAME} ${VERSION}" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDRW -size 200m "${BUILD_DIR}/temp.dmg"

# Mount the DMG
MOUNT_DIR=$(hdiutil attach -readwrite -noverify -noautoopen "${BUILD_DIR}/temp.dmg" | egrep '^/dev/' | sed 1q | awk '{print $3}')

# Create Applications symlink
ln -sf /Applications "${MOUNT_DIR}/Applications"

# Set DMG background and window properties
if [ -f "${ICON_SOURCE}" ]; then
    mkdir -p "${MOUNT_DIR}/.background"
    cp "${ICON_SOURCE}" "${MOUNT_DIR}/.background/background.png"
fi

# Create .DS_Store for DMG layout
cat > "${BUILD_DIR}/dmg_layout.applescript" << 'EOF'
tell application "Finder"
    tell disk "DMG_VOLNAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set the bounds of container window to {400, 100, 900, 400}
        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 72
        set position of item "APP_NAME.app" of container window to {150, 180}
        set position of item "Applications" of container window to {350, 180}
        close
        open
        update without registering applications
        delay 2
    end tell
end tell
EOF

# Replace placeholders in AppleScript
sed -i '' "s/DMG_VOLNAME/${APP_NAME} ${VERSION}/g" "${BUILD_DIR}/dmg_layout.applescript"
sed -i '' "s/APP_NAME/${APP_NAME}/g" "${BUILD_DIR}/dmg_layout.applescript"

# Apply layout (this might fail in headless environments)
osascript "${BUILD_DIR}/dmg_layout.applescript" 2>/dev/null || echo "Warning: Could not apply DMG layout"

# Unmount and compress DMG
hdiutil detach "${MOUNT_DIR}"
hdiutil convert "${BUILD_DIR}/temp.dmg" -format UDZO -imagekey zlib-level=9 -o "${DMG_PATH}"
rm "${BUILD_DIR}/temp.dmg"
rm -f "${BUILD_DIR}/dmg_layout.applescript"

echo "DMG created: ${DMG_PATH}"

# Notarization
if [ "$NOTARIZE" = true ]; then
    if [ -z "$APPLE_ID" ] || [ -z "$APPLE_ID_PASSWORD" ]; then
        echo "Warning: APPLE_ID and APPLE_ID_PASSWORD environment variables required for notarization"
        echo "Skipping notarization step"
    else
        echo "Submitting app for notarization..."
        
        # Create a temporary keychain item for the password
        xcrun notarytool store-credentials "AC_PASSWORD" --apple-id "$APPLE_ID" --password "$APPLE_ID_PASSWORD" ${APPLE_TEAM_ID:+--team-id "$APPLE_TEAM_ID"} 2>/dev/null || true
        
        # Submit for notarization
        xcrun notarytool submit "${DMG_PATH}" --keychain-profile "AC_PASSWORD" --wait
        
        if [ $? -eq 0 ]; then
            echo "Notarization successful!"
            # Staple the notarization ticket
            xcrun stapler staple "${DMG_PATH}"
            echo "Notarization ticket stapled to DMG"
        else
            echo "Notarization failed or timed out"
        fi
    fi
fi

echo ""
echo "Build completed successfully!"
echo "Output directory: ${BUILD_DIR}"
echo ""
echo "Created packages:"
find "${BUILD_DIR}" -name "*.dmg" -o -name "*.app" | sed 's/^/  - /'
echo ""
echo "To install:"
echo "  1. Open ${DMG_NAME}"
echo "  2. Drag ${APP_NAME}.app to Applications folder"
echo "  3. Launch from Applications or Launchpad"

if [ "$SIGN_APP" = false ]; then
    echo ""
    echo "Note: Application is not signed. Users may see security warnings."
    echo "To sign the app, run with --sign option and ensure you have a valid certificate."
fi
