-- set vim options here (vim.<first_key>.<second_key> = value)
local options = {
  opt = {
    -- set to true or false etc.
    list = true,
    listchars = { tab = "»·", extends = "⟩", precedes = "⟨", trail = "·", nbsp = "␣" },
    relativenumber = false,
    tabstop = 4, -- 设置tab宽度为4个空格
    softtabstop = 4, -- 在编辑模式时按退格时的缩回长度
    expandtab = true, -- 用空格表示tab
    shiftwidth = 4, -- shift宽度
    showbreak = "↪ ",
    swapfile = false,
    number = true, -- sets vim.opt.number
    spell = false, -- sets vim.opt.spell
    signcolumn = "auto", -- sets vim.opt.signcolumn to auto
    wrap = true, -- sets vim.opt.wrap
  },
  g = {
    mapleader = " ", -- sets vim.g.mapleader
    autoformat_enabled = true, -- enable or disable auto formatting at start (lsp.formatting.format_on_save must be enabled)
    cmp_enabled = true, -- enable completion at start
    autopairs_enabled = true, -- enable autopairs at start
    diagnostics_mode = 3, -- set the visibility of diagnostics in the UI (0=off, 1=only show in status line, 2=virtual text off, 3=all on)
    icons_enabled = true, -- disable icons in the UI (disable if no nerd font is available, requires :PackerSync after changing)
    ui_notifications_enabled = true, -- disable notifications when toggling UI elements
    resession_enabled = false, -- enable experimental resession.nvim session management (will be default in AstroNvim v4)
  },
}

-- if vim.loop.os_uname().sysname == "Windows_NT" then
--   vim.cmd [[
--     let &shell = 'nu'
--     let &shellcmdflag = '-c'
--     let &shellquote = ""
--     let &shellxquote = ""
--   ]]
-- --   vim.opt.shellcmdflag =
-- --     "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;"

-- --   vim.cmd [[
-- --         let &shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
-- --         let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
-- --         set shellquote= shellxquote=
-- --   ]]
-- end

return options
-- If you need more control, you can use the function()...end notation
-- return function(local_vim)
--   local_vim.opt.relativenumber = true
--   local_vim.g.mapleader = " "
--   local_vim.opt.whichwrap = vim.opt.whichwrap - { 'b', 's' } -- removing option from list
--   local_vim.opt.shortmess = vim.opt.shortmess + { I = true } -- add to option list
--
--   return local_vim
-- end
