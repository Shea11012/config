# prerequisite

1. 安装 zimfw

```bash
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
```

2. 安装必要软件

```bash
# 安装golang的版本管理工具

curl -sSL https://git.io/g-install | sh -s -- zsh



# 安装rust

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2.1 cli tools

- paru instead of pacman and yay

- uutils-coreutils insteadof coreutils

- bat instead of cat

- lsd instead of ls

- fd instead of find

- hyperfine instead of time

- ripgrep instead of grep

- tealdeer instead of tldr

- zoxide instead of cd

- bottom instead of top

- ouch compression and decompression tool

- fnm node version manager

- just instead of make

- dog instead of dig

- jql-bin instead of jq

- wezterm cross-platform terminal write by rust

- xh instead of curl

- rate-mirrors-bin check and update arch mirror

```shell
paru -S uutils-coreutils bat lsd fd hyperfine ripgrep tealdeer zoxide bottom ouch fnm-bin

paru -S dog jql-bin just fzf starship wezterm xh rate-mirrors-bin
```

2.2 language tool

```bash
paru -S beautysh shellcheck lua-format



# node安装prettier

npm i -g prettier
```

# 添加 ArchLinuxCN 源

```shell
# 在 /etc/pacman.conf 添加
[archlinuxcn]
Include = /etc/pacman.d/archlinuxcn-mirrorlist

# 更新 paru -Syyu & paru -S archlinuxcn-keyring
```
