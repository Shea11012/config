vim.o.background = "dark"
vim.g.tokyonight_style = "storm"

local scheme = "tokyonight"

local status,_ = pcall(vim.cmd, "colorscheme ".. scheme)
if not status then
    vim.notify("colorscheme: "..scheme.."not found")
    return
end
