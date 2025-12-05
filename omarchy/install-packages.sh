#!/bin/bash
set -euo pipefail

echo "🔹 🔹 🔹 🔹 🔹 🔹 🔹 🔹 🔹"
echo "  Omarchy Package Installer"
echo "🔹 🔹 🔹 🔹 🔹 🔹 🔹 🔹 🔹"

# インストール対象（公式）
PACMAN_PACKAGES=(
  base-devel
  git
  stow
  unzip
  neovim
  zsh
)

# インストール対象（AUR）
AUR_PACKAGES=(
  google-chrome
  bitwarden-bin
  jetbrains-toolbox
)

echo "[1/3] Installing Official Packages (pacman)"
echo "sudo pacman -S --noconfirm --needed ${PACMAN_PACKAGES[*]}"
sudo pacman -S --noconfirm --needed "${PACMAN_PACKAGES[@]}"

echo "[2/3] Checking AUR helper (yay)"
if command -v yay >/dev/null 2>&1; then
  echo "yay is already installed."
else
  echo "Installing yay (AUR helper)"
  tmpdir=$(mktemp -d)
  echo "Created temp dir: ${tmpdir}"
  git clone https://aur.archlinux.org/yay.git "${tmpdir}/yay"
  pushd "${tmpdir}/yay" >/dev/null
  makepkg -si --noconfirm
  popd >/dev/null
  rm -rf "${tmpdir}"
  echo "yay installed."
fi

echo "[3/3] Installing AUR Packages"
echo "yay -S --noconfirm --needed ${AUR_PACKAGES[*]}"
yay -S --noconfirm --needed "${AUR_PACKAGES[@]}"

echo "✅ Package installation sequence completed."

