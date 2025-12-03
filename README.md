# supplement

Omarchy（Arch Linux）と macOS 向けの dotfiles・環境セットアップスクリプト・上書き設定（overrides）をまとめたリポジトリです。  
共通の開発環境と各OS固有の差分を一元管理して、再セットアップや新規マシン構築を簡単にすることを目的としています。

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

1) 事前に Stow をインストール（Omarchy/Arch は自動、macOS は Homebrew など）

2) デプロイ（ホームディレクトリ直下にシンボリックリンク作成）

```
cd dotfiles
stow -v -R --no-folding zsh p10k ideavim
```

3) 事前確認（ドライラン）

```
stow -n -v -R --no-folding zsh p10k ideavim
```

4) アンデプロイ（削除）

```
stow -D zsh p10k ideavim
```

注意:

- 既存ファイルがあると Stow は失敗します。バックアップ後に再実行するか、手動で退避してください。
- `--adopt` は既存ファイルをリポジトリ側へ取り込むため、通常は推奨しません。

## omarchy

Omarchy 環境特有の設定やスクリプトを配置します。

- hyprland-overrides.conf  
  Omarchy 標準の Hyprland 設定に対して source で読み込ませる追記用設定。
- install_linux.sh  
  dotfiles 展開、Hyprland overrides の追記、必要パッケージのインストールなどを行うセットアップスクリプト。
- その他、Waybar や通知など、Omarchy / Arch 専用の設定ファイル。

## mac

macOS 専用の設定やセットアップスクリプトを配置します。

- install_mac.sh  
  Homebrew、anyenv、CLI ツールなどのインストールと、Mac でも共通で使う dotfiles の展開。
- karabiner.json などキーバインド関連。
- そのほか mac 固有の設定ファイル。

## セットアップ手順（概要）

1. リポジトリをクローンする  
   git clone https://github.com/your-account/supplement.git  
   cd supplement

2. 共通 dotfiles を展開する（GNU Stow）  
   cd dotfiles  
   stow -v -R --no-folding zsh p10k ideavim

3. 各環境ごとのセットアップスクリプトを実行する  
   - Omarchy / Arch: cd ../omarchy && ./install_linux.sh  
   - macOS: cd ../mac && ./install_mac.sh

## シークレットと環境変数

API キーやパスワードなどの秘匿情報はリポジトリには含めません。

- Bitwarden CLI などを使って、セットアップ時に .env や設定ファイルを自動生成する。
- .env や秘匿情報を含むファイルは .gitignore に追加してコミットしない。

## メモ

- Omarchy 環境を基準にしつつ、macOS は「必要なものだけ抜き出して使う」想定です。
- セットアップスクリプトや設定は、何度実行しても壊れない（冪等）ことを目標にします。
