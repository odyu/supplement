#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup hardwares (System Config)"
echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo ""

# ==========================================
# 1. RoBa / BLE Keyboard Connectivity Fixes
# ==========================================

echo "🔸 Configuring Bluetooth Power Management"

# 1-1. カーネルモジュール設定: 省電力機能（Autosuspend）を無効化
echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/bluetooth-disable-autosuspend.conf > /dev/null

# 設定を反映させてカーネルイメージを更新
if command -v mkinitcpio &> /dev/null; then
    sudo mkinitcpio -P
fi

echo "✅ Bluetooth Autosuspend Disabled."
echo ""

echo "🔸 Tuning Bluetooth Configuration (System-wide)"

BT_CONF="/etc/bluetooth/main.conf"

# ヘルパー関数: 設定値の更新
update_bt_config() {
    local param=$1
    local value=$2
    if grep -q "^#\?${param}\s*=" "$BT_CONF"; then
        sudo sed -i "s/^#\?${param}\s*=.*/${param} = ${value}/" "$BT_CONF"
    else
        echo "${param} = ${value}" | sudo tee -a "$BT_CONF" > /dev/null
    fi
}

# [Policy] セクションの確保
if ! grep -q "^\[Policy\]" "$BT_CONF" 2>/dev/null; then
    echo -e "\n[Policy]" | sudo tee -a "$BT_CONF" > /dev/null
fi

# 設定値の適用 (Macライクな挙動にするための重要設定)
update_bt_config "AutoEnable" "true"
update_bt_config "FastConnectable" "true"
update_bt_config "ReconnectAttempts" "7"
update_bt_config "ReconnectIntervals" "1, 2, 4, 8, 16, 32, 64"

# サービス再起動
if systemctl is-active --quiet bluetooth; then
    sudo systemctl restart bluetooth
fi

echo "✅ Bluetooth Configuration optimized."
echo ""

# NOTE: スリープ復帰時の再接続フックは hypridle.conf (ユーザー設定) に移行しました。
# ここでのファイルコピーや権限設定は不要です。

# ==========================================
# 2. Lid Switch Configuration (MacBook)
# ==========================================

echo "🔸 Configuring Lid Switch Action"

# 設定: 蓋を閉じた時の動作
LID_ACTION="poweroff"
LOGIND_CONF="/etc/systemd/logind.conf"

# バックアップ作成
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

# 設定の適用
set_logind_param "HandleLidSwitch" "$LID_ACTION"
set_logind_param "HandleLidSwitchExternalPower" "$LID_ACTION"
set_logind_param "HandleLidSwitchDocked" "ignore"

# 設定を即時反映
sudo systemctl restart systemd-logind

echo "✅ Lid Switch action set to: $LID_ACTION"
echo ""

echo "🎉 Setup hardwares completed."
echo ""