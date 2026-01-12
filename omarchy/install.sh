#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Script directory: ${SCRIPT_DIR}"
echo "Home directory: ${HOME}"
echo ""

"${SCRIPT_DIR}/install-packages.sh"
"${SCRIPT_DIR}/install-dotfiles.sh"
"${SCRIPT_DIR}/setup-packages.sh"
"${SCRIPT_DIR}/setup-hardwares.sh"

echo ""
echo "🔸 Do you want to restart systemd-logind? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "🔸 Restarting systemd-logind..."
    sudo systemctl restart systemd-logind
    echo "✅ systemd-logind restarted."
else
    echo "⏩ Skipped restarting systemd-logind."
fi

echo ""
echo "🎉 All installations and configurations are completed!"
