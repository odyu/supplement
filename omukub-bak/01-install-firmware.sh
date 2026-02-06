#!/bin/bash
set -euo pipefail

echo "=== 01-install-firmware.sh ==="
echo "Installing T2 Mac firmware (Wi-Fi/Bluetooth)..."

if ! command -v get-apple-firmware >/dev/null 2>&1; then
    echo "Error: get-apple-firmware command not found."
    echo "This script is intended for T2 Mac Ubuntu environments."
    exit 1
fi

if sudo get-apple-firmware get_from_online; then
    echo "Firmware installation successful."
    echo "Please REBOOT your Mac to apply changes."
else
    echo "Error: Firmware download failed."
    echo "Try a different firmware version or keep a smartphone screen on nearby and retry."
    exit 1
fi
