#!/bin/bash
set -euo pipefail

echo "=== Install packages ==="
echo ""

echo "Installing package prerequisites"
APT_PACKAGES=(
  curl
  git
  libfuse2
  stow
  zsh
)
sudo apt update
sudo apt install -y "${APT_PACKAGES[@]}"
echo ""

echo "Installing JetBrains Toolbox (AppImage)"
TOOLBOX_APPIMAGE_URL="${TOOLBOX_APPIMAGE_URL:-https://download.jetbrains.com/toolbox/jetbrains-toolbox.AppImage}"
TOOLBOX_DIR="${HOME}/.local/bin"
TOOLBOX_APPIMAGE_PATH="${TOOLBOX_DIR}/jetbrains-toolbox.AppImage"
mkdir -p "${TOOLBOX_DIR}"
if ! curl -fL "${TOOLBOX_APPIMAGE_URL}" -o "${TOOLBOX_APPIMAGE_PATH}"; then
  echo "Failed to download JetBrains Toolbox AppImage from ${TOOLBOX_APPIMAGE_URL}"
  echo "Set TOOLBOX_APPIMAGE_URL to a valid AppImage URL and re-run."
  exit 1
fi
chmod +x "${TOOLBOX_APPIMAGE_PATH}"
echo ""

echo "Installing Toshy"
TOSHY_DIR="${HOME}/.local/share/toshy"
if [ -d "${TOSHY_DIR}" ]; then
  echo "Toshy already cloned at ${TOSHY_DIR}"
else
  git clone https://github.com/RedBearAK/Toshy.git "${TOSHY_DIR}"
fi

if [ -x "${TOSHY_DIR}/install.sh" ]; then
  "${TOSHY_DIR}/install.sh"
else
  bash "${TOSHY_DIR}/install.sh"
fi
echo ""

echo "Package installation completed."
