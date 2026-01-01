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

echo "🔸 Bluetooth Auto-Enable"
# 起動時に必ずBluetoothをONにするように強制する
BT_CONF="/etc/bluetooth/main.conf"

# [Policy] セクションが存在しない場合は追記
if ! grep -q "^\[Policy\]" "$BT_CONF" 2>/dev/null; then
    echo -e "\n[Policy]" | sudo tee -a "$BT_CONF" > /dev/null
fi

# AutoEnable=true を設定
if grep -q "^#\?AutoEnable=true" "$BT_CONF"; then
    sudo sed -i "s/^#\?AutoEnable=true.*/AutoEnable=true/" "$BT_CONF"
elif grep -q "^\[Policy\]" "$BT_CONF"; then
    # [Policy] セクションの直後に挿入
    sudo sed -i "/^\[Policy\]/a AutoEnable=true" "$BT_CONF"
else
    # 最終手段として末尾に追記
    echo "AutoEnable=true" | sudo tee -a "$BT_CONF" > /dev/null
fi

# サービス再起動
if systemctl is-active --quiet bluetooth; then
    sudo systemctl restart bluetooth
fi

echo "✅ Bluetooth Auto-Enable configured."
echo ""

# ==========================================
# Lid Switch Configuration (MacBook)
# ==========================================

echo "🔸 Configuring Lid Switch Action"

# 設定: 蓋を閉じた時の動作
# "poweroff" = シャットダウン (カバンに入れるなら推奨)
# "reboot"   = 再起動 (ログイン画面で待機)
# "suspend"  = スリープ (デフォルト・MacBookでは不安定)
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
# バッテリー駆動時・電源接続時ともに指定のアクション(poweroff)を実行
set_logind_param "HandleLidSwitch" "$LID_ACTION"
set_logind_param "HandleLidSwitchExternalPower" "$LID_ACTION"
# 外部モニタ接続時(Docked)は何もしない
set_logind_param "HandleLidSwitchDocked" "ignore"

# 設定を即時反映
sudo systemctl restart systemd-logind

echo "✅ Lid Switch action set to: $LID_ACTION"
echo ""

echo "🎉 Setup hardwares completed."
echo ""
