#!/bin/bash
set -euo pipefail

echo "=== 03-setup-hardware.sh (Safe Mode) ==="
echo "Applying userspace hardware settings..."

# --- 危険なカーネル変更処理を削除 ---
# T2 Macでのクラッシュを防ぐため、update-initramfs と modprobe は行わない
# ------------------------------------

configure_bluetooth() {
  echo "Tuning Bluetooth configuration (/etc/bluetooth/main.conf)..."
  local bt_conf="/etc/bluetooth/main.conf"

  # 設定ファイルの書き換えのみ行う（再起動不要・安全）
  update_bt_config() {
    local param=$1
    local value=$2
    if grep -q "^#\?${param}\s*=" "${bt_conf}"; then
      sudo sed -i "s/^#\?${param}\s*=.*/${param} = ${value}/" "${bt_conf}"
    else
      echo "${param} = ${value}" | sudo tee -a "${bt_conf}" > /dev/null
    fi
  }

  if [ -f "${bt_conf}" ]; then
    if ! grep -q "^\[Policy\]" "${bt_conf}" 2>/dev/null; then
      echo -e "\n[Policy]" | sudo tee -a "${bt_conf}" > /dev/null
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
    echo "Bluetooth configuration updated (Userspace only)."
  else
    echo "Warning: ${bt_conf} not found. Skipping Bluetooth tuning."
  fi
}

configure_lid_switch() {
  echo "Configuring lid switch action..."
  local lid_action="suspend"
  local logind_conf="/etc/systemd/logind.conf"

  if [ -f "${logind_conf}" ]; then
    # バックアップを作成
    if [ ! -f "${logind_conf}.bak" ]; then
      sudo cp "${logind_conf}" "${logind_conf}.bak"
    fi

    set_logind_param() {
      local param=$1
      local value=$2
      if grep -q "^#\?${param}=" "${logind_conf}"; then
        sudo sed -i "s/^#\?${param}=.*/${param}=${value}/" "${logind_conf}"
      else
        echo "${param}=${value}" | sudo tee -a "${logind_conf}" > /dev/null
      fi
    }

    set_logind_param "HandleLidSwitch" "${lid_action}"
    set_logind_param "HandleLidSwitchExternalPower" "${lid_action}"
    set_logind_param "HandleLidSwitchDocked" "ignore"
    
    # logindのみ再起動（OS再起動は不要）
    sudo systemctl restart systemd-logind
    echo "Lid switch configuration applied."
  else
    echo "Warning: ${logind_conf} not found."
  fi
}

configure_bluetooth
configure_lid_switch

echo "Hardware setup completed (No reboot required)."
