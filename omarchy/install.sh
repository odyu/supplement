#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"
echo "Home directory: ${HOME}"
echo ""

"${SCRIPT_DIR}/install-packages.sh"
"${SCRIPT_DIR}/install-dotfiles.sh"
"${SCRIPT_DIR}/install-hyprland-overrides.sh"
"${SCRIPT_DIR}/setup-pacakges.sh"
