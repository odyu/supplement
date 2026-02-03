#!/bin/bash
set -euo pipefail

echo "=== Setup hardware (Ubuntu) ==="
echo ""

configure_bluetooth() {
  echo "Configuring Bluetooth power management"
  echo "options btusb enable_autosuspend=n" | sudo tee /etc/modprobe.d/bluetooth-disable-autosuspend.conf > /dev/null

  if command -v update-initramfs &> /dev/null; then
    sudo update-initramfs -u
  fi

  echo "Bluetooth autosuspend disabled."
  echo ""

  echo "Tuning Bluetooth configuration"
  local bt_conf="/etc/bluetooth/main.conf"

  update_bt_config() {
    local param=$1
    local value=$2
    if grep -q "^#\\?${param}\\s*=" "${bt_conf}"; then
      sudo sed -i "s/^#\\?${param}\\s*=.*/${param} = ${value}/" "${bt_conf}"
    else
      echo "${param} = ${value}" | sudo tee -a "${bt_conf}" > /dev/null
    fi
  }

  if ! grep -q "^\\[Policy\\]" "${bt_conf}" 2>/dev/null; then
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

  echo "Bluetooth configuration optimized."
  echo ""
}

configure_lid_switch() {
  echo "Configuring lid switch action"
  local lid_action="poweroff"
  local logind_conf="/etc/systemd/logind.conf"

  if [ ! -f "${logind_conf}.bak" ]; then
    sudo cp "${logind_conf}" "${logind_conf}.bak"
  fi

  set_logind_param() {
    local param=$1
    local value=$2
    if grep -q "^${param}=" "${logind_conf}"; then
      sudo sed -i "s/^${param}=.*/${param}=${value}/" "${logind_conf}"
    else
      echo "${param}=${value}" | sudo tee -a "${logind_conf}" > /dev/null
    fi
  }

  set_logind_param "HandleLidSwitch" "${lid_action}"
  set_logind_param "HandleLidSwitchExternalPower" "${lid_action}"
  set_logind_param "HandleLidSwitchDocked" "ignore"

  sudo systemctl restart systemd-logind

  echo "Lid switch action set to: ${lid_action}"
  echo ""
}

apply_t2_extra_tweaks() {
  # Placeholder for T2-specific tweaks (fan control, sensors, etc.).
  # Add commands here when needed.
  :
}

configure_bluetooth
configure_lid_switch
apply_t2_extra_tweaks

echo "Hardware setup completed."
