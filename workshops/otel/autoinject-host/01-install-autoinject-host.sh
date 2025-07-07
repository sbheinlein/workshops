#!/bin/bash
set -e
set -u
set -o pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

REPO_DIR="opentelemetry-injector"

echo "Cloning OpenTelemetry Injector repository..."
if [ -d "$REPO_DIR" ]; then
    echo "Directory '$REPO_DIR' already exists. Removing it to get a fresh clone."
    sudo rm -rf "$REPO_DIR"
fi
git clone https://github.com/open-telemetry/opentelemetry-injector.git

echo "Navigating to $REPO_DIR and building packages..."
cd "$REPO_DIR"
sudo make rpm-package deb-package

echo "Installing OpenTelemetry Injector DEB package..."
cd instrumentation/dist

PACKAGE_NAME=$(ls *.deb)
sudo dpkg -i "$PACKAGE_NAME"
echo "Successfully installed $PACKAGE_NAME"

echo "Adding OpenTelemetry Injector library to ld.so.preload..."
echo /usr/lib/opentelemetry/libotelinject.so | sudo tee -a /etc/ld.so.preload
echo "OpenTelemetry Injector setup complete."

echo "Cleaning up cloned repository..."
sudo rm -rf "$REPO_DIR"
echo "Cleanup complete."
# You can update the config values in /etc/opentelemetry/otelinject