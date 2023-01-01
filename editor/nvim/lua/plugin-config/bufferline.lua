local status, bufferline = pcall(require,"bufferline")
if not status then
    vim.notify("not found bufferline")
    return
end

bufferline.setup({
    options = {
        -- 关闭tab
        close_command = "bd! %d",
        right_mouse_command = "bd! %d",

        -- 侧边栏配置
        offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              hightlight = "Directory",
              text_align = "left",
            },
        },

        diagnostics = "nvim_lsp",
    },
})
