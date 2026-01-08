#!/bin/bash
set -euo pipefail

# スクリプトのディレクトリ解決
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# リポジトリルート (install/config/ から ../.. でルートへ)
REPO_ROOT=$(cd "$SCRIPT_DIR/../../" && pwd)

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
fi

echo "✅ Bluetooth Configuration optimized."
echo ""

# ==========================================
# 2. Systemd Sleep Hook (Deploy from bin)
# ==========================================

echo "🔸 Installing Sleep/Wake Hook for RoBa"

# ソース: リポジトリ内の bin/roba-reconnect
SOURCE_BIN="$REPO_ROOT/bin/roba-reconnect"
# ターゲット: systemdフック用ディレクトリ
DEST_HOOK="/etc/systemd/system-sleep/roba-reconnect.sh"

if [ -f "$SOURCE_BIN" ]; then
    # ファイルをコピー
    sudo cp "$SOURCE_BIN" "$DEST_HOOK"
    # 実行権限を付与 (必須)
    sudo chmod +x "$DEST_HOOK"

    echo "✅ Hook installed from bin: $DEST_HOOK"
else
    echo "❌ Error: Source binary not found at $SOURCE_BIN"
    # 開発中のパス不整合を防ぐため、ここでのexit 1は避け、警告にとどめるか選択可能
    # exit 1
fi

echo ""

# ==========================================
# 3. Lid Switch Configuration
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

sudo systemctl restart systemd-logind

echo "✅ Lid Switch action set to: $LID_ACTION"
echo ""

echo "🎉 Setup hardwares completed."
echo ""