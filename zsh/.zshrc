export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting fzf-tab rust)

source $ZSH/oh-my-zsh.sh

export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

fastfetch
alias reload="source ~/.zshrc"
alias cd="z"
alias ls="eza --icons --group-directories-first"
alias ll="eza --icons --group-directories-first -l"
alias cat="bat"
alias lg="lazygit"
alias cls="clear"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- FZF Catppuccin Mocha Theme ---
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--prompt='∼ ' --pointer='▶' --marker='✓' \
--bind 'ctrl-/:change-preview-window(down|hidden|)'"
# --- FZF x Ripgrep Integration ---

export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git"'

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Ctrl+T: Tìm file và xem trước bằng Bat
export FZF_CTRL_T_OPTS="
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Ctrl+R: Tìm lịch sử lệnh (History)
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'Press CTRL-Y to copy command into clipboard'"

fif() {
  if [ ! "$1" ]; then
    echo "Usage: fif <string>"
    return 1
  fi
  rg --files-with-matches --no-messages "$1" | fzf --preview "highlight -O ansi -l {} 2> /dev/null | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' || rg --ignore-case --pretty --context 10 '$1' {}"
}

# 3. CẤU HÌNH FZF-TAB (Mới thêm)
# Khi bấm Tab, dùng màu sắc của LS (Eza) để hiển thị
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Xem trước nội dung thư mục khi Tab vào lệnh cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# Xem trước nội dung file khi Tab vào lệnh cat/bat/vim
zstyle ':fzf-tab:complete:*:*' fzf-preview 'less ${(Q)realpath}'
zstyle ':fzf-tab:complete:*:*' fzf-flags --height=40%

# Added by Antigravity
export PATH="/Users/nghiatran/.antigravity/antigravity/bin:$PATH"

# GOLANG
export GOROOT="/usr/local/go"
export GOPRIVATE="github.com/nghiatrann0502/*"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export HOMEBREW_CASK_OPTS="--fontdir=/Library/Fonts"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# RUST
export PATH="$HOME/.cargo/bin:$PATH"
