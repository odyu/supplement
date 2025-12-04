# supplement

Omarchy（Arch Linux）と macOS 向けの dotfiles・環境セットアップスクリプト・上書き設定（overrides）をまとめたリポジトリです。  
共通の開発環境と各OS固有の差分を一元管理して、再セットアップや新規マシン構築を簡単にすることを目的としています。

前提（自分用の固定運用）:

- 本リポジトリは固定パスに配置します: $HOME/supplement
- スクリプトはこの固定パス前提で動作します（パスを変えると失敗します）

## ディレクトリ構成

supplement/
- dotfiles/ … 共通の設定ファイル（zsh, vim, git, terminal など）
- omarchy/ … Omarchy / Arch Linux 用の設定・スクリプト
- mac/ … macOS 用の設定・スクリプト

## dotfiles

共通の設定ファイルを GNU Stow のパッケージとして管理します。

構成（例）:

- dotfiles/
  - zsh/
    - .zshrc
  - p10k/
    - .p10k.zsh
  - ideavim/
    - .ideavimrc
  - （今後）git/, nvim/, tmux/, config/ghostty/ などを追加可能

使い方:

1) 事前準備（GNU Stow を入れる）

- Arch/Omarchy: sudo pacman -S stow
- macOS: brew install stow

2) デプロイ（ホームディレクトリ直下にシンボリックリンク作成）

- スクリプトで一括（固定パス前提）:

```
bash "$HOME/supplement/omarchy/install-dotfiles.sh"
```

- 手動で実行する場合（3行で明示的に）:

```
cd "$HOME/supplement/dotfiles"
stow -v -R --no-folding -t "$HOME" zsh
stow -v -R --no-folding -t "$HOME" p10k
stow -v -R --no-folding -t "$HOME" ideavim
```

3) 事前確認（ドライラン）

```
cd "$HOME/supplement/dotfiles"
stow -n -v -R --no-folding -t "$HOME" zsh
stow -n -v -R --no-folding -t "$HOME" p10k
stow -n -v -R --no-folding -t "$HOME" ideavim
```

4) アンデプロイ（削除）

```
cd "$HOME/supplement/dotfiles"
stow -D -t "$HOME" zsh p10k ideavim
```

注意:

- 既存ファイルがあると Stow は失敗します。バックアップ後に再実行するか、手動で退避してください。
- `--adopt` は既存ファイルをリポジトリ側へ取り込むため、通常は推奨しません。
- stow 未インストール時はエラー終了（127）になります。先に Stow を入れてください。

## omarchy

Omarchy 環境特有の設定やスクリプトを配置します。

- hyprland-overrides.conf  
  Omarchy 標準の Hyprland 設定に対して source で読み込ませる追記用設定。
- install.sh  
  必要パッケージのインストールや各種設定を行うセットアップスクリプト。
- その他、Waybar や通知など、Omarchy / Arch 専用の設定ファイル。

## mac

macOS 専用の設定やセットアップスクリプトを配置します。

- install.sh  
  Homebrew、anyenv、CLI ツールなどのインストールと、Mac でも共通で使う dotfiles の展開。
- karabiner.json などキーバインド関連。
- そのほか mac 固有の設定ファイル。

## セットアップ手順（概要）

1. リポジトリを固定パスにクローンする  
   git clone https://github.com/your-account/supplement.git "$HOME/supplement"  
   cd "$HOME/supplement"

2. 共通 dotfiles を展開する（GNU Stow）  
   bash "$HOME/supplement/omarchy/install-dotfiles.sh"

3. 各環境ごとのセットアップスクリプトを実行する  
   - Omarchy / Arch: cd omarchy && ./install.sh  
   - macOS: cd mac && ./install.sh

## シークレットと環境変数

API キーやパスワードなどの秘匿情報はリポジトリには含めません。

- Bitwarden CLI などを使って、セットアップ時に .env や設定ファイルを自動生成する。
- .env や秘匿情報を含むファイルは .gitignore に追加してコミットしない。

## メモ

- Omarchy 環境を基準にしつつ、macOS は「必要なものだけ抜き出して使う」想定です。
- セットアップスクリプトや設定は、何度実行しても壊れない（冪等）ことを目標にします。
