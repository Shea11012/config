-- leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = {noremap = true, silent = true}

local map = vim.api.nvim_set_keymap

-- $跳转到行尾不带空格
map("v", "$", "g_", opt)
map("v", "g_", "$", opt)
map("n", "$", "g_", opt)
map("n", "g_", "$", opt)

map("n", "<leader>w", ":w<CR>", opt)
map("n", "<leader>wq", ":wq<CR>", opt)
map("n", "<leader>q", ":qa!<cr>", opt)

vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'",
               {expr = true, silent = true})
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'",
               {expr = true, silent = true})

-- 上下滚动浏览
-- ctrl u / ctrl + d  只移动9行，默认移动半屏
map("n", "<C-u>", "10k", opt)
map("n", "<C-d>", "10j", opt)

-- magic search
map("n", "/", "/\\v", {noremap = true, silent = false})
map("v", "/", "/\\v", {noremap = true, silent = false})

-- visual模式下缩进代码
map("v", "<", "<gv", opt)
map("v", ">", ">gv", opt)
-- 上下移动选中文本
map("v", "J", ":move '>+1<CR>gv-gv", opt)
map("v", "K", ":move '<-2<CR>gv-gv", opt)

-- 在visual mode 里粘贴不要复制
map("v", "p", '"_dP', opt)

-- window 分屏快捷键
-- 取消s默认功能
map("n", "s", "", opt)

-- 垂直切分
map("n", "sv", ":vs<CR>", opt)
-- 水平切分
map("n", "sh", ":sp<CR>", opt)

-- 关闭当前
map("n", "sc", "<C-w>c", opt)

-- alt + hjkl, 窗口之间跳转
map("n", "<A-h>", "<C-w>h", opt)
map("n", "<A-j>", "<C-w>j", opt)
map("n", "<A-k>", "<C-w>k", opt)
map("n", "<A-l>", "<C-w>l", opt)

-- esc 退回normal模式
map("t", "<Esc>", "<C-\\><C-n>", opt)

-- plugins --------------------------------------------------------
local pluginKeys = {}

-- nvim-tree
map("n", "<C-t>", ":NvimTreeToggle<CR>", opt)

-- bufferline
-- 左右tab切换
map("n", "<C-h>", ":BufferLineCyclePrev<CR>", opt)
map("n", "<C-l>", ":BufferLineCycleNext<CR>", opt)
-- 关闭当前tab
map("n", "<C-w>", ":bd<CR>", opt)

-- markdownpreview
map("n", "<C-m>", ":MarkdownPreview<CR>", opt)

return pluginKeys
