#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup hardwares"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

# ==========================================
# RoBa / BLE Keyboard Connectivity Fixes
# ==========================================

echo "🔸 Bluetooth Power Management"
# Bluetoothチップの省電力機能（勝手なスリープ）を殺す
echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/bluetooth-disable-autosuspend.conf > /dev/null

# 設定を反映させてカーネルイメージを更新
if command -v mkinitcpio &> /dev/null; then
    sudo mkinitcpio -P
fi

echo "✅ Bluetooth Power Management Disabled."
echo ""

echo "🎉 Setup hardwares completed."
echo ""
