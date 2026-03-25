#!/bin/bash

set -e

DESKTOP="$HOME/Desktop"
APP_NAME="scloud_desktop"
BUILD_DIR="build/linux/x64/release/bundle"

echo "Building $APP_NAME..."
flutter build linux --release

echo "Copying to Desktop..."
rm -rf "$DESKTOP/$APP_NAME"
cp -r "$BUILD_DIR" "$DESKTOP/$APP_NAME"

echo "Done! App is at $DESKTOP/$APP_NAME"
echo "Run it with: $DESKTOP/$APP_NAME/$APP_NAME"
