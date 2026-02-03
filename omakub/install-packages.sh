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
if [ -d "/opt/jetbrains-toolbox" ]; then
  echo "JetBrains Toolbox already installed at /opt/jetbrains-toolbox, skipping download."
elif [ -f "${TOOLBOX_APPIMAGE_PATH}" ]; then
  echo "JetBrains Toolbox AppImage already exists at ${TOOLBOX_APPIMAGE_PATH}, skipping download."
else
  mkdir -p "${TOOLBOX_DIR}"
  if ! curl -fL "${TOOLBOX_APPIMAGE_URL}" -o "${TOOLBOX_APPIMAGE_PATH}"; then
    echo "Failed to download JetBrains Toolbox AppImage from ${TOOLBOX_APPIMAGE_URL}"
    echo "Set TOOLBOX_APPIMAGE_URL to a valid AppImage URL and re-run."
    exit 1
  fi
  chmod +x "${TOOLBOX_APPIMAGE_PATH}"
fi
echo ""

echo "Installing Toshy"
TOSHY_DIR="${HOME}/Toshy"
if [ -d "${TOSHY_DIR}" ]; then
  if [ -d "${TOSHY_DIR}/.git" ]; then
    echo "Updating Toshy at ${TOSHY_DIR}"
    if ! git -C "${TOSHY_DIR}" pull --ff-only; then
      echo "Toshy update failed; keeping existing checkout."
    fi
  else
    echo "Toshy directory exists but is not a git repo, skipping clone."
  fi
else
  git clone https://github.com/RedBearAK/Toshy.git "${TOSHY_DIR}"
fi

if [ -f "${TOSHY_DIR}/install.sh" ]; then
  if [ -x "${TOSHY_DIR}/install.sh" ]; then
    "${TOSHY_DIR}/install.sh"
  else
    bash "${TOSHY_DIR}/install.sh"
  fi
else
  echo "Toshy install script not found at ${TOSHY_DIR}/install.sh"
fi
echo ""

echo "Installing mise"
if command -v mise >/dev/null 2>&1; then
  echo "mise already installed."
else
  echo "curl https://mise.run | sh"
  curl https://mise.run | sh
fi
echo ""

echo "Package installation completed."
