#!/bin/bash
set -euo pipefail

echo "=== 05-install-jetbrains.sh ==="
echo "Installing JetBrains Toolbox..."

TOOLBOX_TARBALL_URL="https://data.services.jetbrains.com/products/download?code=TBA&platform=linux"
INSTALL_DIR="${HOME}/.local/bin"
TOOLBOX_BIN_PATH="${INSTALL_DIR}/jetbrains-toolbox"

mkdir -p "${INSTALL_DIR}"

TMP_DIR="$(mktemp -d)"
TARBALL="${TMP_DIR}/jetbrains-toolbox.tar.gz"

cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Downloading JetBrains Toolbox..."
if ! curl -fL "${TOOLBOX_TARBALL_URL}" -o "${TARBALL}"; then
  echo "Error: Failed to download JetBrains Toolbox."
  exit 1
fi

echo "Extracting..."
tar -xzf "${TARBALL}" -C "${TMP_DIR}"

EXTRACTED_BIN="$(find "${TMP_DIR}" -type f -name jetbrains-toolbox -print -quit)"
if [ -z "${EXTRACTED_BIN}" ]; then
  echo "Error: Failed to locate jetbrains-toolbox binary after extraction."
  exit 1
fi

echo "Installing to ${TOOLBOX_BIN_PATH}..."
install -m 0755 "${EXTRACTED_BIN}" "${TOOLBOX_BIN_PATH}"

echo "JetBrains Toolbox installation completed."
