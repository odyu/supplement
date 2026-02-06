#!/bin/bash
set -euo pipefail

echo "=== 02-install-omakub.sh ==="
echo "Installing Omakub base system..."

# Omakub installation
wget -qO- https://omakub.org/install | bash

echo "Omakub base system installation triggered."
