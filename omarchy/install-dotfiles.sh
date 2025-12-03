#!/bin/bash

set -euo pipefail

echo "---------------------------------------"
echo "[Dotfiles] Deploying via GNU Stow"
echo "---------------------------------------"

REPO_ROOT="$(cd "$(dirname "$0")"/.. && pwd)"
DOTFILES_DIR="$REPO_ROOT/dotfiles"

# Ensure GNU Stow is available
if ! command -v stow >/dev/null 2>&1; then
  echo "[stow] Not found. Attempting to install (pacman)..."
  if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S --noconfirm --needed stow
  else
    echo "[ERROR] GNU Stow is required but not installed. Please install it and re-run." >&2
    exit 1
  fi
fi

cd "$DOTFILES_DIR"

# Determine stow packages present in dotfiles/
PACKAGES=()
for pkg in zsh p10k ideavim; do
  [ -d "$pkg" ] && PACKAGES+=("$pkg")
done

if [ ${#PACKAGES[@]} -eq 0 ]; then
  echo "[WARN] No Stow packages found (expected one of: zsh, p10k, ideavim). Nothing to do."
  exit 0
fi

echo "[stow] Packages to deploy: ${PACKAGES[*]}"

# Build stow options
STOW_OPTS=(-v -R --no-folding -t "$HOME")

# Optional dry run: set STOW_DRY_RUN=1 to preview
if [ "${STOW_DRY_RUN:-0}" = "1" ]; then
  STOW_OPTS+=(-n)
  echo "[stow] Dry run enabled (STOW_DRY_RUN=1)."
fi

# Note: We intentionally do NOT use --adopt to avoid modifying repository files.
# On conflicts, Stow will exit non‑zero. Users can resolve or remove existing files.

set +e
stow "${STOW_OPTS[@]}" "${PACKAGES[@]}"
RC=$?
set -e

if [ $RC -ne 0 ]; then
  echo "[ERROR] Stow failed. This typically means files already exist at the target locations."
  echo "        Please remove or back up conflicting files, then re-run this script."
  echo "        Tip (preview): STOW_DRY_RUN=1 bash omarchy/install-dotfiles.sh"
  exit $RC
fi

echo "[Dotfiles] Deployment via Stow completed."
