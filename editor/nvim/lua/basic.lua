-- vim.g.loaded_python3_provider = 0
vim.g.ensure_installed = {"rust", "go"}
vim.g.encoding = "UTF-8"
vim.o.fileencoding = "utf-8"

-- jkhl 移动时周围光标保留8行
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8

-- 使用相对行号
vim.wo.number = true
vim.wo.relativenumber = true

-- 高亮所在行
vim.wo.cursorline = true

-- 显示左侧图标指示列
vim.wo.signcolumn = "yes"

-- 右侧参考线
-- vim.wo.colorcolumn = "80"

-- 设置tab宽度为4个字符
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true

-- space代替tab
vim.o.expandtab = true
vim.bo.expandtab = true

-- 设置缩进为4个字符
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4

-- 新行对齐当前行
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true

-- 搜索大小写不敏感,除非包含大写
vim.o.ignorecase = true
vim.o.smartcase = true

-- 搜索不高亮
vim.o.hlsearch = false

-- 边输边搜
vim.o.incsearch = true

-- 命令行高
vim.o.cmdheight = 1

-- 当文件被外部程序修改时，自动加载
vim.o.autoread = true
vim.bo.autoread = true

-- 禁止拆行
vim.wo.wrap = false

-- 光标在行首尾时可以跳到下一行
vim.o.whichwrap = "<,>,[,]"

-- 允许隐藏被修改过的buffer
vim.o.hidden = true

-- 禁止backup、swap文件
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- smaller update, unit:ms
vim.o.updatetime = 200

-- 等待键盘快捷键连击时间,unit: ms
-- vim.o.timeoutlen = 500

-- split window
vim.o.splitbelow = true
vim.o.splitright = true

-- 补全增强
vim.o.wildmenu = true
-- 自动补全不自动选中
vim.g.completeopt = "menu,menuone,noselect,noinsert"
vim.o.shortmess = vim.o.shortmess .. "c"
vim.o.pumheight = 10

-- 永远显示tabline
vim.o.showtabline = 2

-- 使用增强状态栏插件后不需要vim的模式提示
vim.o.showmode = false

-- 剪贴板
vim.opt.clipboard = "unnamedplus"

-- 开启真色
vim.o.termguicolors = true
vim.opt.termguicolors = true

-- 显示不可见字符
vim.o.list = true
-- 不可见字符显示
vim.o.listchars = "tab:»·,nbsp:+,trail:·,extends:→,precedes:←"

vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --hidden --vimgrep --smart-case --"

vim.o.wildignore =
    ".git,.hg,*.jpg,*.jpeg,*.png,*.gif,*.zip,**/tmp/**,*.DS_Store,**/node_modules/**"
vim.o.wildignorecase = true
