#!/bin/bash
set -euo pipefail

echo "=== 03-setup-hardware.sh (Safe Mode) ==="
echo "Configuring hardware safety and power settings..."

# -----------------------------------------------------------------------------
# 1. Audio Safety Setup (T2 Mac Speakers Protection)
# -----------------------------------------------------------------------------
configure_audio_safety() {
  echo "Applying T2 Audio Safety Config (UCM)..."

  local TMP_DIR
  TMP_DIR="$(mktemp -d)"

  cleanup() {
    rm -rf "${TMP_DIR}"
  }
  trap cleanup EXIT

  if ! git clone --depth=1 https://github.com/t2linux/audio-config.git "${TMP_DIR}"; then
    echo "Error: Failed to clone audio-config repository."
    echo "Check your internet connection."
    exit 1
  fi

  echo "Installing UCM profiles..."
  if [ -d "${TMP_DIR}/ucm2" ]; then
    sudo mkdir -p /usr/share/alsa/ucm2
    sudo cp -r "${TMP_DIR}/ucm2/"* /usr/share/alsa/ucm2/
  fi

  if [ -d "${TMP_DIR}/conf" ]; then
    sudo cp -r "${TMP_DIR}/conf/"* /usr/share/alsa/ucm2/conf.d/ 2>/dev/null || true
  fi

  # オーディオのリロードは安全なので実行
  systemctl --user restart pipewire wireplumber 2>/dev/null || true

  echo "Audio safety profiles installed."
}

# -----------------------------------------------------------------------------
# 2. Lid Switch Setup (Power Management)
# -----------------------------------------------------------------------------
configure_lid_switch() {
  echo "Configuring lid switch action (Always Suspend)..."
  local lid_action="suspend"
  local logind_conf="/etc/systemd/logind.conf"

  if [ -f "${logind_conf}" ]; then
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

    # どんな状況でも蓋を閉じたらサスペンド（安全第一）
    set_logind_param "HandleLidSwitch" "${lid_action}"
    set_logind_param "HandleLidSwitchExternalPower" "${lid_action}"
    set_logind_param "HandleLidSwitchDocked" "${lid_action}"

    # 【修正】ここで restart systemd-logind を実行しない！
    # クラッシュ回避のため、設定書き換えのみで留める。
    echo "Lid switch configuration written."
  else
    echo "Warning: ${logind_conf} not found. Skipping lid config."
  fi
}

# --- Execution ---
configure_audio_safety
configure_lid_switch

echo ""
echo "Hardware setup completed."
echo "Please REBOOT your Mac manually to apply Lid Switch settings."