#!/bin/bash

# Build .deb using FPM (Effing Package Management)
# Install FPM first: sudo gem install fpm

set -e

APP_NAME="packaroo"
VERSION="2.0.0"
DESCRIPTION="A modern Java application packaging tool"
MAINTAINER="Damoiskii <moimyazz@gmail.com>"
HOMEPAGE="https://github.com/damoiskii/Packaroo"

echo "Building Flutter application..."
flutter build linux --release

echo "Building .deb package with FPM..."
fpm -s dir -t deb \
    --name "${APP_NAME}" \
    --version "${VERSION}" \
    --description "${DESCRIPTION}" \
    --maintainer "${MAINTAINER}" \
    --url "${HOMEPAGE}" \
    --license "MIT" \
    --category "devel" \
    --depends "libc6" \
    --depends "libgtk-3-0" \
    --depends "libglib2.0-0" \
    --prefix /usr \
    --deb-compression xz \
    --after-install post-install.sh \
    --after-remove post-remove.sh \
    build/linux/x64/release/bundle/=/lib/packaroo/ \
    assets/icons/icon.png=/share/pixmaps/packaroo.png \
    linux/packaroo.desktop=/share/applications/

echo "Package built successfully!"
