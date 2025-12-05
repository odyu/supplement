# ==============================================================================
# Powerlevel10k Instant Prompt
# ==============================================================================
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ==============================================================================
# Common Environment
# ==============================================================================
export LANG=en_US.UTF-8

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme setting
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
# anyenvを使う場合、rbenv/nodenvプラグインは競合の可能性がありますが補完用に残してもOK
plugins=(git yarn aliases gem iterm2 npm rails rake rbenv node nodenv bundler)

source $ZSH/oh-my-zsh.sh

# ==============================================================================
# Tools
# ==============================================================================

# Load anyenv automatically
if [ -d "$HOME/.anyenv" ]; then
    export PATH="$HOME/.anyenv/bin:$PATH"
    eval "$(anyenv init - zsh)"
fi

# ==============================================================================
# OS Specific Settings
# ==============================================================================

case "$(uname -s)" in
    Darwin*)
        # ----------------------------------------------------------------------
        # macOS Specific
        # ----------------------------------------------------------------------

        # --- Homebrew Setup ---
        # 1. パスの追加 (Apple Silicon用)
        # これを先にやらないと次の `type brew` が失敗します
        if [ -x /opt/homebrew/bin/brew ]; then
            export PATH="/opt/homebrew/bin:$PATH"
        fi

        # 2. Brew環境変数の読み込み & 依存設定
        if type brew &>/dev/null; then
            # Homebrew基本変数 (HOMEBREW_PREFIXなど)
            eval "$(brew shellenv)"

            # コンパイル用パス
            export LIBRARY_PATH="$HOMEBREW_PREFIX/lib:$LIBRARY_PATH"
            export CPATH="$HOMEBREW_PREFIX/include:$CPATH"

            # Ruby build settings
            export PATH="$HOMEBREW_PREFIX/opt/bison/bin:$PATH"
            export LDFLAGS="-L$HOMEBREW_PREFIX/lib"
            export PKG_CONFIG_PATH="$HOMEBREW_PREFIX/opt/libffi/lib/pkgconfig"
            export RUBY_CFLAGS="-w"
            export CPPFLAGS="-Wno-incompatible-function-pointer-types -Wno-implicit-function-declaration"

            # zsh-completions
            FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
            FPATH="$(brew --prefix)/share/zsh-completions:${FPATH}"
            autoload -Uz compinit && compinit

            # Homebrew middlewares (keg-only)
            export PATH="$HOMEBREW_PREFIX/opt/jpeg/bin:$PATH"
            export PATH="$HOMEBREW_PREFIX/opt/imagemagick@6/bin:$PATH"
            export PATH="$HOMEBREW_PREFIX/opt/mysql@5.7/bin:$PATH"
            export PATH="$HOMEBREW_PREFIX/opt/openjdk/bin:$PATH"
        fi

        # Mac Aliases
        alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
        ;;

    Linux*)
        # ----------------------------------------------------------------------
        # Linux (Omarchy) Specific
        # ----------------------------------------------------------------------

        # Pacman Aliases
        alias pac="sudo pacman"
        alias yay="yay --noconfirm"

        # Color settings
        if [[ -x /usr/bin/dircolors ]]; then
            test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
            alias ls='ls --color=auto'
        fi
        ;;
esac

# ==============================================================================
# Common Aliases
# ==============================================================================
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git pull'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias reload='source ~/.zshrc'

# ==============================================================================
# Theme Configuration
# ==============================================================================
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ==============================================================================
# Secrets & Local Settings
# ==============================================================================

# Load zshrc for secrets (Git ignored - for API Keys)
[[ ! -f ~/.zshrc.secrets ]] || source ~/.zshrc.secrets

# Load zshrc for local machine specific settings (Git ignored - for temp paths)
[[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
