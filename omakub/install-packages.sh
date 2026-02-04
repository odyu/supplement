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

echo "Installing JetBrains Toolbox (tar.gz)"
TOOLBOX_TARBALL_URL="${TOOLBOX_TARBALL_URL:-https://data.services.jetbrains.com/products/download?code=TBA&platform=linux}"
TOOLBOX_DIR="${HOME}/.local/bin"
TOOLBOX_BIN_PATH="${TOOLBOX_DIR}/jetbrains-toolbox"
if [ -d "/opt/jetbrains-toolbox" ]; then
  echo "JetBrains Toolbox already installed at /opt/jetbrains-toolbox, skipping download."
elif [ -f "${TOOLBOX_BIN_PATH}" ]; then
  echo "JetBrains Toolbox already exists at ${TOOLBOX_BIN_PATH}, skipping download."
else
  mkdir -p "${TOOLBOX_DIR}"
  TOOLBOX_TMP_DIR="$(mktemp -d)"
  TOOLBOX_TARBALL="${TOOLBOX_TMP_DIR}/jetbrains-toolbox.tar.gz"
  cleanup_toolbox_tmp() {
    rm -rf "${TOOLBOX_TMP_DIR}"
  }
  trap cleanup_toolbox_tmp EXIT
  if ! curl -fL "${TOOLBOX_TARBALL_URL}" -o "${TOOLBOX_TARBALL}"; then
    echo "Failed to download JetBrains Toolbox tarball from ${TOOLBOX_TARBALL_URL}"
    echo "Set TOOLBOX_TARBALL_URL to a valid tar.gz URL and re-run."
    exit 1
  fi
  tar -xzf "${TOOLBOX_TARBALL}" -C "${TOOLBOX_TMP_DIR}"
  TOOLBOX_EXTRACTED_BIN="$(find "${TOOLBOX_TMP_DIR}" -type f -name jetbrains-toolbox -print -quit)"
  if [ -z "${TOOLBOX_EXTRACTED_BIN}" ]; then
    echo "Failed to locate jetbrains-toolbox binary after extraction."
    exit 1
  fi
  mv "${TOOLBOX_EXTRACTED_BIN}" "${TOOLBOX_BIN_PATH}"
  chmod +x "${TOOLBOX_BIN_PATH}"
  trap - EXIT
  cleanup_toolbox_tmp
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
