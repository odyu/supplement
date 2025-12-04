#!/bin/bash
set -euo pipefail

echo "[Omarchy] Setup: anyenv init 設定とデフォルトシェルを zsh へ変更します"

MARKER_START="# >>> anyenv (omarchy) >>>"
MARKER_END="# <<< anyenv (omarchy) <<<"

ensure_block() {
  local target_file="$1"
  local block_content="$2"

  mkdir -p "$(dirname "$target_file")"
  touch "$target_file"

  if grep -qF "$MARKER_START" "$target_file"; then
    echo "  - $target_file: 既に設定済みのためスキップ"
  else
    {
      echo ""
      echo "$MARKER_START"
      echo "$block_content"
      echo "$MARKER_END"
    } >> "$target_file"
    echo "  - $target_file: anyenv の初期化ブロックを追記しました"
  fi
}

# 1) zsh の設定ファイルに anyenv の PATH と init を追加（冪等）
ZSHENV_FILE="$HOME/.zshenv"
ZSHRC_FILE="$HOME/.zshrc"

ANYENV_PATH_BLOCK='export PATH="$HOME/.anyenv/bin:$PATH"'
ensure_block "$ZSHENV_FILE" "$ANYENV_PATH_BLOCK"

ANYENV_INIT_BLOCK='if command -v anyenv >/dev/null 2>&1; then
  eval "$(anyenv init - zsh)"
fi'
ensure_block "$ZSHRC_FILE" "$ANYENV_INIT_BLOCK"

# 2) デフォルトシェルを zsh に切り替え（存在し、かつ現在 zsh でない場合のみ）
ZSH_PATH="$(command -v zsh || true)"
CURRENT_SHELL_PATH="${SHELL:-}"

if [[ -n "$ZSH_PATH" ]]; then
  if [[ "$CURRENT_SHELL_PATH" != "$ZSH_PATH" ]]; then
    echo "[Omarchy] デフォルトシェルを zsh ($ZSH_PATH) に変更します…"
    if chsh -s "$ZSH_PATH" "$USER" 2>/dev/null; then
      echo "  - chsh 成功: 次回ログインから zsh が使用されます"
    else
      if chsh -s "$ZSH_PATH" 2>/dev/null; then
        echo "  - chsh 成功 (ユーザー省略): 次回ログインから zsh"
      else
        echo "  - chsh に失敗しました。必要なら手動で以下を実行してください:"
        echo "      chsh -s $ZSH_PATH $USER"
      fi
    fi
  else
    echo "[Omarchy] 既にデフォルトシェルは zsh ($ZSH_PATH) です。変更は不要です"
  fi
else
  echo "[Omarchy] zsh が見つかりませんでした。シェルの変更はスキップします"
fi

echo "[Omarchy] anyenv/zsh 設定が完了しました。新しいシェル設定を反映するには、新しいターミナルを開くか再ログインしてください。"