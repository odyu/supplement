#!/bin/bash
set -euo pipefail

WORK_DIR="$(pwd -P)"

confirm_or_return() {
  local option_name="$1"
  local reply
  read -r -p "Ready to execute ${option_name}. Are you sure? [y/N]: " reply || true
  case "${reply}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

install_dependencies() {
  local packages=()
  if ! command -v stow >/dev/null 2>&1; then
    packages+=("stow")
  fi
  if ! command -v curl >/dev/null 2>&1; then
    packages+=("curl")
  fi
  if ! command -v git >/dev/null 2>&1; then
    packages+=("git")
  fi

  if [ "${#packages[@]}" -gt 0 ]; then
    sudo apt update
    sudo apt install -y "${packages[@]}"
  fi
}

run_personal_scripts() {
  local scripts=(
    "install-packages.sh"
    "install-dotfiles.sh"
    "setup-hardware.sh"
    "setup-packages.sh"
  )

  local script
  for script in "${scripts[@]}"; do
    local src="${WORK_DIR}/omakub/${script}"
    if [ ! -f "${src}" ]; then
      echo "Missing script: ${src}"
      exit 1
    fi
    bash "${src}"
  done
}

while true; do
  echo "=== Omakub T2 Setup Menu ==="
  echo "1) Install T2 Firmware (Wi-Fi/Bluetooth)"
  echo "2) Install Omakub Base System"
  echo "3) Run Personal Setup (Packages & Dotfiles)"
  echo "q) Quit"
  echo ""
  read -r -p "Select an option: " choice || true
  echo ""

  case "${choice}" in
    1)
      if ! confirm_or_return "Install T2 Firmware (Wi-Fi/Bluetooth)"; then
        continue
      fi
      if ! sudo get-apple-firmware get_from_online; then
        echo "Firmware download failed."
        echo "Try a different firmware version or keep a smartphone screen on nearby and retry."
        exit 1
      fi
      echo "Installation Complete. Please REBOOT your Mac now."
      exit 0
      ;;
    2)
      if ! confirm_or_return "Install Omakub Base System"; then
        continue
      fi
      wget -qO- https://omakub.org/install | bash
      echo "Omakub Base installed."
      exit 0
      ;;
    3)
      if ! confirm_or_return "Run Personal Setup (Packages & Dotfiles)"; then
        continue
      fi
      install_dependencies
      run_personal_scripts
      echo "All setup complete!"
      exit 0
      ;;
    q|Q)
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid selection. Please choose 1, 2, 3, or q."
      echo ""
      ;;
  esac
done
