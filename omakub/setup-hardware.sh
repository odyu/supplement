#!/bin/bash
set -euo pipefail

echo "=== Setup hardware (Ubuntu) ==="
echo ""

# ==========================================
# 1. Bluetooth Connectivity Fixes
# ==========================================

echo "Configuring Bluetooth power management"
echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/bluetooth-disable-autosuspend.conf > /dev/null

if command -v update-initramfs &> /dev/null; then
  sudo update-initramfs -u
fi

echo "Bluetooth autosuspend disabled."
echo ""

echo "Tuning Bluetooth configuration"
BT_CONF="/etc/bluetooth/main.conf"

update_bt_config() {
  local param=$1
  local value=$2
  if grep -q "^#\\?${param}\\s*=" "$BT_CONF"; then
    sudo sed -i "s/^#\\?${param}\\s*=.*/${param} = ${value}/" "$BT_CONF"
  else
    echo "${param} = ${value}" | sudo tee -a "$BT_CONF" > /dev/null
  fi
}

if ! grep -q "^\\[Policy\\]" "$BT_CONF" 2>/dev/null; then
  echo -e "\n[Policy]" | sudo tee -a "$BT_CONF" > /dev/null
fi

update_bt_config "AutoEnable" "true"
update_bt_config "FastConnectable" "true"
update_bt_config "ReconnectAttempts" "7"
update_bt_config "ReconnectIntervals" "1, 2, 4, 8, 16, 32, 64"

if systemctl is-active --quiet bluetooth; then
  sudo systemctl restart bluetooth
else
  sudo systemctl enable --now bluetooth
fi

echo "Bluetooth configuration optimized."
echo ""

# ==========================================
# 2. Lid Switch Configuration
# ==========================================

echo "Configuring lid switch action"
LID_ACTION="poweroff"
LOGIND_CONF="/etc/systemd/logind.conf"

if [ ! -f "${LOGIND_CONF}.bak" ]; then
  sudo cp "$LOGIND_CONF" "${LOGIND_CONF}.bak"
fi

set_logind_param() {
  local param=$1
  local value=$2
  if grep -q "^$param=" "$LOGIND_CONF"; then
    sudo sed -i "s/^$param=.*/$param=$value/" "$LOGIND_CONF"
  else
    echo "$param=$value" | sudo tee -a "$LOGIND_CONF" > /dev/null
  fi
}

set_logind_param "HandleLidSwitch" "$LID_ACTION"
set_logind_param "HandleLidSwitchExternalPower" "$LID_ACTION"
set_logind_param "HandleLidSwitchDocked" "ignore"

sudo systemctl restart systemd-logind

echo "Lid switch action set to: $LID_ACTION"
echo ""

echo "Hardware setup completed."
