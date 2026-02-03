#!/bin/bash
set -euo pipefail


echo ""
echo "🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶"
echo "🔶"
echo "🔶   INSTALL SUPPLEMENT"
echo "🔶"
echo "🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶 🔶"
echo ""

# --- OS Detection ---
OS_NAME="$(uname -s)"
IS_UBUNTU="false"
if [ -f /etc/lsb-release ] && grep -qi "Ubuntu" /etc/lsb-release; then
  IS_UBUNTU="true"
elif [ -f /etc/os-release ] && grep -qi "Ubuntu" /etc/os-release; then
  IS_UBUNTU="true"
fi

if [ "$OS_NAME" == "Darwin" ]; then
  echo "💻  Detected OS: macOS 🍎"
elif [ "${IS_UBUNTU}" == "true" ]; then
  echo "💻  Detected OS: Omakub (Ubuntu) 🐧"
elif [ -f /etc/arch-release ]; then
  echo "💻  Detected OS: Omarchy (Arch Linux) 🐧"
else
  echo "💻  Detected OS: Unknown OS ❓"
fi
echo ""

GIT_STATUS=$(git status --porcelain)

if [ -z "$GIT_STATUS" ]; then
  echo -e "✅  No changes found. Working tree is clean."
  echo ""
else
  echo -e "⚠️  Uncommitted changes files !"
  echo ""
  git status
fi

if [ "$OS_NAME" == "Darwin" ]; then
  mac/install.sh
elif [ "${IS_UBUNTU}" == "true" ]; then
  omakub/install.sh
elif [ -f /etc/arch-release ]; then
  omarchy/install.sh
fi

echo ""
echo "😄  FINISHED SUPPLEMENT 😄"
echo ""
