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
if [ "$OS_NAME" == "Darwin" ]; then
  echo "💻  Detected OS: macOS 🍎"
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
elif [ -f /etc/arch-release ]; then
  omarchy/install.sh
fi

echo ""
echo "😄  FINISHED SUPPLEMENT 😄"
echo ""
