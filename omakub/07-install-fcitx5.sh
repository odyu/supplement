#!/bin/bash
set -euo pipefail

echo "=== 07-install-fcitx5.sh ==="
echo "Optimizing Japanese input environment (Fcitx5)..."

# 1. Install fcitx5 and fcitx5-mozc
echo "Installing fcitx5 and fcitx5-mozc..."
sudo apt update
sudo apt install -y fcitx5 fcitx5-mozc im-config

# 2. Switch from IBus to Fcitx5
echo "Switching input method to Fcitx5..."
im-config -n fcitx5

echo "Fcitx5 installation and configuration completed."
echo "Note: You may need to log out and log back in for changes to take effect."
