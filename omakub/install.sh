#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}/.local/share/omakub/install/personal"

echo "Preparing Omakub personal scripts"
echo "Source directory: ${SCRIPT_DIR}"
echo "Target directory: ${TARGET_DIR}"
echo ""

mkdir -p "${TARGET_DIR}"

SCRIPTS=(
  "install-dotfiles.sh"
  "install-packages.sh"
  "setup-hardware.sh"
  "setup-packages.sh"
)

for script in "${SCRIPTS[@]}"; do
  src="${SCRIPT_DIR}/${script}"
  if [ ! -f "${src}" ]; then
    echo "Missing script: ${src}"
    exit 1
  fi

  echo "Copying ${script} to ${TARGET_DIR}"
  cp -f "${src}" "${TARGET_DIR}/"
  chmod +x "${TARGET_DIR}/${script}"
done

echo ""
echo "Omakub personal scripts installed."
