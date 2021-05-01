#/bin/bash

home=$1
if [ -z $home]; then
	echo "pleas enter HOME dir";
	return;
fi


echo "cp nvim config to $home/.config...";
cp -R ./nvim $home/.config/nvim

echo "download vim plugin manager...";
if command -v nvim > /dev/null 2>&1; then
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
		       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
else
	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
		    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo ".zshrc config to $home...";
cp zshrc/.zshrc $home;

echo "download zplug...";
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

