# prerequisite

1. 安装 zimfw

```bash
curl -fsSL https://raw.githubusercontent.com/zimfw/install/master/install.zsh | zsh
```

2. 安装必要软件

```bash
paru -S fzf beautysh shellcheck lua-format unzip starship

# 安装golang的版本管理工具
curl -sSL https://git.io/g-install | sh -s -- zsh

# 安装node版本管理工具
curl -L https://bit.ly/n-install | bash

# node安装prettier
npm i -g prettier

# 安装rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

2.1 cli tools

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

```shell
paru -S uutils-coreutils bat lsd fd hyperfine ripgrep tealdeer zoxide bottom ouch
```
