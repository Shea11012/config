# Environment
export EDITOR="nvim"
export FZF_DEFAULT_OPTS="--inline-info --height 60% --ansi --border"
# rootless docker daemon
if command -v rg &> /dev/null && ! uname -a | rg -i "wsl"; then
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
fi

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# rust mirror
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"

# alias
alias vim="nvim"
