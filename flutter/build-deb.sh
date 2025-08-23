#!/bin/bash

# Packaroo Debian Package Builder
# This script builds a .deb package from your Flutter Linux build

set -e

# Configuration
APP_NAME="packaroo"
VERSION="2.0.0"
ARCH="amd64"
MAINTAINER="Damoiskii <moimyazz@gmail.com>"
DESCRIPTION="A modern Java application packaging tool"
HOMEPAGE="https://github.com/damoiskii/Packaroo"

# Directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/debian-package"
PKG_DIR="${BUILD_DIR}/${APP_NAME}-${VERSION}"
FLUTTER_BUILD_DIR="${SCRIPT_DIR}/build/linux/x64/release/bundle"

echo "Building Flutter application..."
flutter build linux --release

echo "Creating package directory structure..."
rm -rf "${BUILD_DIR}"
mkdir -p "${PKG_DIR}/DEBIAN"
mkdir -p "${PKG_DIR}/usr/bin"
mkdir -p "${PKG_DIR}/usr/lib/${APP_NAME}"
mkdir -p "${PKG_DIR}/usr/share/applications"
mkdir -p "${PKG_DIR}/usr/share/pixmaps"

echo "Creating control file..."
cat > "${PKG_DIR}/DEBIAN/control" << EOF
Package: ${APP_NAME}
Version: ${VERSION}
Section: devel
Priority: optional
Architecture: ${ARCH}
Depends: libc6, libgtk-3-0, libglib2.0-0
Maintainer: ${MAINTAINER}
Description: ${DESCRIPTION}
 Packaroo is a modern Flutter desktop application for packaging Java
 applications with jpackage and jlink. It provides an intuitive GUI
 for creating distributable Java application packages.
Homepage: ${HOMEPAGE}
EOF

echo "Copying application files..."
cp -r "${FLUTTER_BUILD_DIR}"/* "${PKG_DIR}/usr/lib/${APP_NAME}/"

echo "Creating launcher script..."
cat > "${PKG_DIR}/usr/bin/${APP_NAME}" << 'EOF'
#!/bin/bash
cd /usr/lib/packaroo
exec ./packaroo "$@"
EOF
chmod +x "${PKG_DIR}/usr/bin/${APP_NAME}"

echo "Creating desktop entry..."
cat > "${PKG_DIR}/usr/share/applications/${APP_NAME}.desktop" << EOF
[Desktop Entry]
Name=Packaroo
Comment=${DESCRIPTION}
GenericName=Java Package Manager
Exec=${APP_NAME}
Icon=${APP_NAME}
StartupNotify=true
NoDisplay=false
Type=Application
Categories=Development;
Keywords=java;packaging;jpackage;jlink;development;
EOF

echo "Copying icon..."
if [ -f "assets/icons/icon.png" ]; then
    cp "assets/icons/icon.png" "${PKG_DIR}/usr/share/pixmaps/${APP_NAME}.png"
else
    echo "Warning: Icon not found at assets/icons/icon.png"
fi

echo "Building .deb package..."
dpkg-deb --build "${PKG_DIR}"

echo "Package built successfully: ${BUILD_DIR}/${APP_NAME}-${VERSION}.deb"

# Optional: Test the package
if command -v lintian &> /dev/null; then
    echo "Running lintian checks..."
    lintian "${BUILD_DIR}/${APP_NAME}-${VERSION}.deb" || true
fi

echo "To install the package, run:"
echo "sudo dpkg -i ${BUILD_DIR}/${APP_NAME}-${VERSION}.deb"
echo "sudo apt-get install -f  # If there are dependency issues"
