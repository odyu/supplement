#!/bin/bash
set -euo pipefail

# スクリプトのディレクトリ解決
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup hardwares (Bin Distribution)"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

# ==========================================
# 1. RoBa / BLE Keyboard Connectivity Fixes
# ==========================================

echo "🔸 Configuring Bluetooth Power Management"

# 1-1. Autosuspend 無効化
echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/bluetooth-disable-autosuspend.conf > /dev/null

if command -v mkinitcpio &> /dev/null; then
    sudo mkinitcpio -P
fi

echo "✅ Bluetooth Autosuspend Disabled."
echo ""

echo "🔸 Tuning Bluetooth Configuration"

BT_CONF="/etc/bluetooth/main.conf"

update_bt_config() {
    local param=$1
    local value=$2
    if grep -q "^#\?${param}\s*=" "$BT_CONF"; then
        sudo sed -i "s/^#\?${param}\s*=.*/${param} = ${value}/" "$BT_CONF"
    else
        echo "${param} = ${value}" | sudo tee -a "$BT_CONF" > /dev/null
    fi
}

if ! grep -q "^\[Policy\]" "$BT_CONF" 2>/dev/null; then
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

echo "✅ Bluetooth Configuration optimized."
echo ""

# ==========================================
# 2. Lid Switch Configuration
# ==========================================

echo "🔸 Configuring Lid Switch Action"

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

# sudo systemctl restart systemd-logind

echo "✅ Lid Switch action set to: $LID_ACTION"
echo ""

# ==========================================
# 3. Timezone Configuration
# ==========================================

echo "🔸 Setting Timezone to Asia/Tokyo"
sudo timedatectl set-timezone Asia/Tokyo
echo "✅ Timezone set to Asia/Tokyo."
echo ""

# ==========================================
# 4. Keyd Configuration (Mac Parity)
# ==========================================

echo "🔸 Configuring keyd"

sudo mkdir -p /etc/keyd
sudo cp "${SCRIPT_DIR}/keyd/default.conf" /etc/keyd/default.conf

sudo systemctl enable --now keyd

# Add user to keyd group (required for socket communication)
sudo usermod -aG keyd "$USER"

# Setup keyd-application-mapper as a user service
USER_SYSTEMD_DIR="${HOME}/.config/systemd/user"
mkdir -p "${USER_SYSTEMD_DIR}"

cat > "${USER_SYSTEMD_DIR}/keyd-application-mapper.service" << EOF
[Unit]
Description=Keyd Application Mapper
After=graphical-session.target
PartOf=graphical-session.target

[Service]
Type=simple
ExecStart=/usr/bin/keyd-application-mapper
Restart=always

[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now keyd-application-mapper

echo "✅ keyd and application mapper configured."
echo ""

echo "🎉 Setup hardwares completed."