# ==============================================================================
# PLATFORM DETECTION
# ==============================================================================
export OS_TYPE="$(uname -s)"   # "Darwin" = macOS, "Linux" = Linux
is_mac()   { [[ "$OS_TYPE" == "Darwin" ]]; }
is_linux() { [[ "$OS_TYPE" == "Linux"  ]]; }

# ==============================================================================
# OH-MY-ZSH
# ==============================================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf fzf-tab rust)
source $ZSH/oh-my-zsh.sh

# ==============================================================================
# TERMINAL — True color + undercurl support (Ghostty / tmux / neovim)
# ==============================================================================
# Ghostty sets $TERM=xterm-ghostty; nếu KHÔNG trong tmux thì giữ nguyên để
# Ghostty tự xử lý true color qua terminfo của nó.
# Nếu TRONG tmux, tmux sẽ override $TERM thành tmux-256color (xem .tmux.conf).
# KHÔNG ép xterm-256color ở đây — làm mất true color capability.

# Chỉ fallback khi terminfo thực sự không có entry cho terminal hiện tại
if [[ -n "$TERM" ]] && ! infocmp "$TERM" &>/dev/null; then
  export TERM=xterm-256color
fi

# Báo cho các app (neovim, delta, lazygit…) biết terminal hỗ trợ true color
export COLORTERM=truecolor

# ==============================================================================
# EDITOR
# ==============================================================================
if command -v nvim &>/dev/null; then
  export EDITOR='nvim'
else
  export EDITOR='vim'
fi
export VISUAL="$EDITOR"

# ==============================================================================
# TMUX — auto-start hoặc attach khi mở terminal (tùy chọn, bỏ comment để bật)
# ==============================================================================
# Tự động vào tmux session khi mở terminal mới (ngoài tmux, không phải SSH pipe)
# if command -v tmux &>/dev/null && [[ -z "$TMUX" && -z "$SSH_TTY" && -t 1 ]]; then
#   tmux attach-session -t default 2>/dev/null || tmux new-session -s default
# fi

# Alias tmux tiện dụng
if command -v tmux &>/dev/null; then
  alias ta="tmux attach-session -t"       # ta <name>
  alias tl="tmux list-sessions"
  alias tn="tmux new-session -s"          # tn <name>
  alias tk="tmux kill-session -t"         # tk <name>
  alias td="tmux detach"

  # Mở neovim trong tmux popup (quick scratch)
  nvp() {
    local file="${1:-}"
    tmux popup -d "#{pane_current_path}" -w 90% -h 90% -E "nvim $file"
  }
fi

# ==============================================================================
# CLIPBOARD — cross-platform, tmux OSC 52 passthrough
# ==============================================================================
# Trong tmux, dùng OSC 52 để sync clipboard qua SSH và không cần xclip/pbcopy.
# Neovim cũng dùng OSC 52 nếu set clipboard=unnamedplus + có provider.
# Usage: echo "text" | clipboard_copy
clipboard_copy() {
  if [[ -n "$TMUX" ]]; then
    # OSC 52 passthrough qua tmux (hoạt động cả khi SSH)
    local data
    data="$(cat | base64 | tr -d '\n')"
    printf '\033Ptmux;\033\033]52;c;%s\007\033\\' "$data"
  elif is_mac; then
    pbcopy
  elif command -v xclip &>/dev/null; then
    xclip -selection clipboard
  elif command -v xsel &>/dev/null; then
    xsel --clipboard --input
  elif command -v wl-copy &>/dev/null; then
    wl-copy   # Wayland
  else
    cat       # fallback: no-op
  fi
}

# ==============================================================================
# PATH — build incrementally, dedup at the end
# ==============================================================================

# Homebrew (macOS / Linux)
if is_mac; then
  # Apple Silicon default; Intel fallback
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Go
export GOROOT="/usr/local/go"
export GOPATH="$HOME/go"
export GOPRIVATE="github.com/nghiatran0502/*"
export PATH="$GOPATH/bin:$PATH"

# Rust / Cargo
export PATH="$HOME/.cargo/bin:$PATH"

# Antigravity (macOS only)
is_mac && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

# Remove duplicate PATH entries
typeset -U path PATH

# ==============================================================================
# HOMEBREW OPTS (macOS only)
# ==============================================================================
is_mac && export HOMEBREW_CASK_OPTS="--fontdir=/Library/Fonts"

# ==============================================================================
# NVM
# ==============================================================================
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ]             && source "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ]    && source "$NVM_DIR/bash_completion"

# ==============================================================================
# PYENV
# ==============================================================================
export PYENV_ROOT="$HOME/.pyenv"
[[ -d "$PYENV_ROOT/bin" ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv &>/dev/null && eval "$(pyenv init - zsh)"

# ==============================================================================
# ALIASES
# ==============================================================================
alias reload="source ~/.zshrc"
alias cls="clear"
alias lg="lazygit"

# ls → eza (with fallback to ls)
if command -v eza &>/dev/null; then
  alias ls="eza --icons --group-directories-first"
  alias ll="eza --icons --group-directories-first -l"
  alias la="eza --icons --group-directories-first -la"
else
  alias ll="ls -lh"
  alias la="ls -lah"
fi

# cat → bat (with fallback)
command -v bat  &>/dev/null && alias cat="bat"
command -v batcat &>/dev/null && alias cat="batcat"   # Ubuntu package name

# ==============================================================================
# ZOXIDE  (replaces cd — must come after PATH is set)
# ==============================================================================
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh --cmd cd)"   # zoxide owns "cd" natively
fi

# ==============================================================================
# FZF
# ==============================================================================
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--prompt='∼ ' --pointer='▶' --marker='✓' \
--bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Determine bat binary name (differs between macOS and Ubuntu)
_bat_cmd="$(command -v bat || command -v batcat)"

export FZF_CTRL_T_OPTS="
  --preview '${_bat_cmd:=cat} -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'Press CTRL-Y to copy command into clipboard'"

# fif: find file containing string, preview with rg highlights
fif() {
  if [[ -z "$1" ]]; then
    echo "Usage: fif <string>"
    return 1
  fi
  rg --files-with-matches --no-messages "$1" \
    | fzf --preview "highlight -O ansi -l {} 2>/dev/null \
        | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
        || rg --ignore-case --pretty --context 10 '$1' {}"
}

# ==============================================================================
# FZF-TAB
# ==============================================================================
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':fzf-tab:complete:cd:*'   fzf-preview 'eza -1 --color=always $realpath 2>/dev/null || ls $realpath'
zstyle ':fzf-tab:complete:*:*'    fzf-preview  'bat --color=always ${(Q)realpath} 2>/dev/null || less ${(Q)realpath}'
zstyle ':fzf-tab:complete:*:*'    fzf-flags --height=40%

# ==============================================================================
# STARSHIP PROMPT
# ==============================================================================
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ==============================================================================
# FASTFETCH — chỉ chạy ở pane/window đầu tiên của tmux session,
#             hoặc khi không dùng tmux; không chạy khi source lại
# ==============================================================================
_should_fastfetch() {
  command -v fastfetch &>/dev/null || return 1
  [[ -n "$ZSH_EXECUTION_STRING" ]] && return 1   # đang bị source programmatically

  if [[ -n "$TMUX" ]]; then
    # Chỉ chạy trong window 0, pane 0 của session (cửa sổ đầu tiên)
    local win pane
    win="$(tmux display-message -p '#I')"
    pane="$(tmux display-message -p '#P')"
    [[ "$win" == "0" && "$pane" == "0" ]]
  else
    [[ $SHLVL -eq 1 ]]
  fi
}

_should_fastfetch && fastfetch
