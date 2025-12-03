#!/bin/bash

set -e

# Wrapper script delegating to Makefile-based installer
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "[DEPRECATED] install.sh is now a thin wrapper. Please run: make install"

if command -v make >/dev/null 2>&1; then
  make -C "$SCRIPT_DIR" install
else
  echo "Error: 'make' is not installed."
  echo "You can run platform scripts directly as a fallback:"
  case "$(uname -s)" in
    Darwin*)
      chmod +x "$SCRIPT_DIR/mac/install.sh" || true
      "$SCRIPT_DIR/mac/install.sh"
      ;;
    Linux*)
      chmod +x "$SCRIPT_DIR/omarchy/install.sh" || true
      "$SCRIPT_DIR/omarchy/install.sh"
      ;;
    *)
      echo "Unsupported OS: $(uname -s)"
      exit 1
      ;;
  esac
fi