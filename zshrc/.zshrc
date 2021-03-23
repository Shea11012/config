source ~/.zplug/init.zsh

export EDITOR=vim

# plugin g switch go version
#export GOROOT=$HOME/.g/go
#export G_MIRROR=https://golang.google.cn/dl/
#export PATH=$PATH:$HOME/.g/go/bin

# custom script
export PATH=$HOME/bin:/usr/local/bin:$PATH
for f in ~/script/*.sh
do
	source $f;
done

# alias
alias vim=nvim

# zplug plugins
zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-history-substring-search"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-syntax-highlighting"

if ! zplug check --verbose; then
	printf "Install? [y/N]: "
	if read -q; then
		echo; zplug install
	fi
fi

zplug load
