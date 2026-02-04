#!/bin/bash
set -euo pipefail

echo "=== 03-setup-hardware.sh (Audio & Lid) ==="
echo "Configuring hardware behaviors..."

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
    set_logind_param "HandleLidSwitchDocked" "${lid_action}"
    
    # logindのみ再起動（OS再起動は不要）
    sudo systemctl restart systemd-logind
    echo "Lid switch configuration applied."
  else
    echo "Warning: ${logind_conf} not found."
  fi
}

configure_audio_safety() {
  echo "Applying T2 Mac Audio Safety (UCM profiles)..."
  
  local tmp_dir
  tmp_dir=$(mktemp -d)

  # 1. Clone the t2linux/audio-config repository
  echo "Cloning t2linux/audio-config..."
  if git clone --depth 1 https://github.com/t2linux/audio-config "${tmp_dir}"; then
    
    # 2. Copy UCM2 profiles to /usr/share/alsa/ucm2/
    if [ -d "${tmp_dir}/ucm2" ]; then
      echo "Copying UCM2 profiles..."
      sudo mkdir -p /usr/share/alsa/ucm2
      sudo cp -r "${tmp_dir}/ucm2/"* /usr/share/alsa/ucm2/
    fi

    # 3. Copy audio config files to /etc/modprobe.d/
    if [ -d "${tmp_dir}/conf" ]; then
      echo "Applying modprobe configurations..."
      sudo cp "${tmp_dir}/conf/"*.conf /etc/modprobe.d/ 2>/dev/null || true
    fi

    # 4. Reload PipeWire/PulseAudio
    echo "Reloading audio services..."
    if command -v systemctl >/dev/null && [ -n "${USER:-}" ]; then
      # Reload PipeWire/WirePlumber if present
      systemctl --user restart pipewire pipewire-pulse wireplumber 2>/dev/null || true
    fi
    # Also attempt to kill pulseaudio to force reload if not using pipewire
    pulseaudio -k 2>/dev/null || true
    
    echo "Audio safety configuration completed."
  else
    echo "Error: Failed to clone audio-config repository. Skipping audio setup."
  fi

  # Cleanup
  rm -rf "${tmp_dir}"
}

configure_lid_switch
configure_audio_safety

echo "Hardware setup completed."
