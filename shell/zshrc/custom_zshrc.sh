# Environment
export EDITOR="nvim"
export FZF_DEFAULT_OPTS="--inline-info --height 60% --ansi --border"
# rootless docker daemon
export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock

#pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# alias
alias vim="nvim"
