#!/bin/bash
set -euo pipefail

echo "🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸🔸"
echo "🔸 Setup hardwares (Updated)"
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

echo "🔸 Tuning Bluetooth Configuration (Mac-like Behavior)"

BT_CONF="/etc/bluetooth/main.conf"

# ヘルパー関数: 設定値の更新（存在すれば置換、なければ追記は簡易的なsedで対応）
update_bt_config() {
    local param=$1
    local value=$2
    if grep -q "^#\?${param}\s*=" "$BT_CONF"; then
        sudo sed -i "s/^#\?${param}\s*=.*/${param} = ${value}/" "$BT_CONF"
    else
        # セクションがない場合の簡易追記（本来はセクション判定すべきだが、末尾追記で動作するケースが多い）
        echo "${param} = ${value}" | sudo tee -a "$BT_CONF" > /dev/null
    fi
}

# 1-2. main.conf の最適化
# [Policy] セクションが存在しない場合は追記
if ! grep -q "^\[Policy\]" "$BT_CONF" 2>/dev/null; then
    echo -e "\n[Policy]" | sudo tee -a "$BT_CONF" > /dev/null
fi

# 設定値の適用
# 起動時にコントローラーをON (必須)
update_bt_config "AutoEnable" "true"
# Macと同様に接続要求を頻繁にチェック (FastConnectable)
update_bt_config "FastConnectable" "true"
# 再接続の粘り強さを強化
update_bt_config "ReconnectAttempts" "7"
update_bt_config "ReconnectIntervals" "1, 2, 4, 8, 16, 32, 64"

# サービス再起動
if systemctl is-active --quiet bluetooth; then
    sudo systemctl restart bluetooth
fi

echo "✅ Bluetooth Configuration optimized."
echo ""

# ==========================================
# 2. Systemd Sleep Hook (Wakeup Reconnect)
# ==========================================

echo "🔸 Installing Sleep/Wake Hook for RoBa"

HOOK_PATH="/etc/systemd/system-sleep/roba-reconnect.sh"

# スリープ復帰時に強制的にBluetoothを叩き起こし、roBaを探して接続するスクリプトを作成
sudo tee "$HOOK_PATH" << 'EOF' > /dev/null
#!/bin/bash
# Omarchy Hook: Reconnect RoBa on system wake
if [ "${1}" == "post" ]; then
    # コントローラーの電源リセット
    bluetoothctl power on
    sleep 2
    # 登録済みの "roBa" を探して接続 (MACアドレスが変わっても追従)
    MAC_ADDR=$(bluetoothctl devices | grep "roBa" | awk '{print $2}' | head -n 1)
    if [ -n "$MAC_ADDR" ]; then
        bluetoothctl connect "$MAC_ADDR"
    fi
fi
EOF

sudo chmod +x "$HOOK_PATH"

echo "✅ Sleep hook installed to $HOOK_PATH"
echo ""

# ==========================================
# 3. Lid Switch Configuration (MacBook)
# ==========================================

echo "🔸 Configuring Lid Switch Action"

# 設定: 蓋を閉じた時の動作
LID_ACTION="poweroff"
LOGIND_CONF="/etc/systemd/logind.conf"

# バックアップ作成
if [ ! -f "${LOGIND_CONF}.bak" ]; then
    sudo cp "$LOGIND_CONF" "${LOGIND_CONF}.bak"
fi

# 設定変更のための関数
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