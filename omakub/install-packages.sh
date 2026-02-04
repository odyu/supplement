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

echo "Installing Oh My Zsh"
if [ -d "${HOME}/.oh-my-zsh" ]; then
  echo "Oh My Zsh already installed."
else
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi
echo ""

echo "Installing JetBrains Toolbox (tar.gz)"
TOOLBOX_TARBALL_URL="${TOOLBOX_TARBALL_URL:-https://data.services.jetbrains.com/products/download?code=TBA&platform=linux}"
TOOLBOX_DIR="${HOME}/.local/bin"
TOOLBOX_BIN_PATH="${TOOLBOX_DIR}/jetbrains-toolbox"
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
install -m 0755 "${TOOLBOX_EXTRACTED_BIN}" "${TOOLBOX_BIN_PATH}"
trap - EXIT
cleanup_toolbox_tmp
echo ""

echo "Installing Toshy"
TOSHY_DIR="${HOME}/toshy"
if [ -d "${TOSHY_DIR}/.git" ]; then
  echo "Updating Toshy at ${TOSHY_DIR}"
  if ! git -C "${TOSHY_DIR}" pull --ff-only; then
    echo "Toshy update failed; keeping existing checkout."
  fi
elif [ -d "${TOSHY_DIR}" ]; then
  echo "Toshy directory exists but is not a git repo, skipping clone."
else
  (cd "${HOME}" && git clone https://github.com/RedBearAK/toshy.git)
fi

if [ -f "${TOSHY_DIR}/setup_toshy.py" ]; then
  if [ -x "${TOSHY_DIR}/setup_toshy.py" ]; then
    (cd "${TOSHY_DIR}" && sudo ./setup_toshy.py install)
  else
    (cd "${TOSHY_DIR}" && sudo python3 ./setup_toshy.py install)
  fi
else
  echo "Toshy setup script not found at ${TOSHY_DIR}/setup_toshy.py"
fi
echo ""

echo "Installing mise"
MISE_BIN=""
if command -v mise >/dev/null 2>&1; then
  MISE_BIN="$(command -v mise)"
elif [ -x "${HOME}/.local/bin/mise" ]; then
  MISE_BIN="${HOME}/.local/bin/mise"
else
  echo "curl https://mise.run | sh"
  curl https://mise.run | sh
  MISE_BIN="${HOME}/.local/bin/mise"
fi
if [ ! -x "${MISE_BIN}" ]; then
  echo "mise binary not found at ${MISE_BIN}"
  exit 1
fi
"${MISE_BIN}" use -g github-cli lazygit
echo ""

echo "Package installation completed."
