#!/bin/bash
set -euo pipefail

# Work directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${SCRIPT_DIR}"

# Atomic Scripts List
SCRIPTS=(
  "01-install-firmware.sh"
  "02-install-omakub.sh"
  "03-setup-hardware.sh"
  "04-install-zsh-env.sh"
  "05-install-jetbrains.sh"
  "06-install-toshy.sh"
  "07-install-fcitx5.sh"
  "08-install-dotfiles.sh"
)

confirm() {
  local msg="$1"
  read -r -p "${msg} [y/N]: " reply || true
  case "${reply}" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

run_script() {
  local script="$1"
  if [ -f "${script}" ]; then
    echo "--- Executing ${script} ---"
    bash "${script}"
    echo "--- Finished ${script} ---"
    echo ""
  else
    echo "Error: Script ${script} not found."
  fi
}

run_all() {
  echo "Running all scripts sequentially..."
  for script in "${SCRIPTS[@]}"; do
    run_script "${script}"
  done
}

while true; do
  echo "=== Omakub Atomic Setup Launcher ==="
  echo "A) Run All (Sequential)"
  for i in "${!SCRIPTS[@]}"; do
    echo "$((i+1))) ${SCRIPTS[$i]}"
  done
  echo "Q) Quit"
  echo ""
  read -r -p "Select an option: " choice || true
  echo ""

  case "${choice}" in
    [Aa])
      if confirm "Run all scripts?"; then
        run_all
        echo "All scripts executed."
        exit 0
      fi
      ;;
    [1-8])
      idx=$((choice-1))
      script="${SCRIPTS[$idx]}"
      if confirm "Run ${script}?"; then
        run_script "${script}"
      fi
      ;;
    [Qq])
      echo "Exiting."
      exit 0
      ;;
    *)
      echo "Invalid selection."
      ;;
  esac
done
