#!/bin/bash
set -euo pipefail

echo "=== 03-setup-hardware.sh (Safe Mode) ==="
echo "Configuring hardware safety and power settings..."

# -----------------------------------------------------------------------------
# 1. Audio Safety Setup (T2 Mac Speakers Protection)
# -----------------------------------------------------------------------------
configure_audio_safety() {
  echo "Applying T2 Audio Safety Config (Official Package)..."

  # T2 Linuxの公式リポジトリからオーディオ設定パッケージをインストール
  # これにより、UCMプロファイル等の安全設定が自動配置されます
  echo "Installing apple-t2-audio-config..."
  if sudo apt update && sudo apt install -y apple-t2-audio-config; then
    echo "Audio config package installed successfully."
  else
    echo "Warning: apt install failed. Checking fallback..."
    # 万が一リポジトリがない場合の手動適用（kekrby版を利用）
    local TMP_DIR
    TMP_DIR="$(mktemp -d)"
    if git clone --depth=1 https://github.com/kekrby/t2-better-audio.git "${TMP_DIR}"; then
       sudo cp -r "${TMP_DIR}/ucm2/"* /usr/share/alsa/ucm2/ 2>/dev/null || true
       sudo cp -r "${TMP_DIR}/conf/"* /usr/share/alsa/ucm2/conf.d/ 2>/dev/null || true
       echo "Fallback audio config installed."
       rm -rf "${TMP_DIR}"
    else
       echo "Error: Could not install audio config. Please check internet connection."
    fi
  fi

  echo "Reloading audio services..."
  # 設定反映のためにサービス再起動（安全）
  systemctl --user restart pipewire wireplumber 2>/dev/null || true

  echo "Audio safety profiles applied."
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

    # 修正: ここでの systemctl restart systemd-logind はクラッシュ回避のため削除済み
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