#!/bin/bash
# Omarchy Tool: Force reconnect RoBa keyboard
# 手動実行、または systemd-sleep フックから呼び出されることを想定

# 引数 $1 が "post" (スリープ復帰) または 空 (手動実行) の場合に実行
if [ "${1:-post}" == "post" ]; then
    # 1. Bluetoothコントローラーを確実に叩き起こす
    bluetoothctl power on

    # 2. 安定化待機
    sleep 2

    # 3. "roBa" のMACアドレスを動的に特定
    MAC_ADDR=$(bluetoothctl devices | grep "roBa" | awk '{print $2}' | head -n 1)

    # 4. 接続試行
    if [ -n "$MAC_ADDR" ]; then
        echo "Omarchy: Attempting to connect to roBa ($MAC_ADDR)..."
        bluetoothctl connect "$MAC_ADDR"
    else
        echo "Omarchy: roBa device not found in paired list."
    fi
fi