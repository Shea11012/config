local status,nvim_tree = pcall(require, "nvim-tree")
if not status then
    vim.notify("not found nvim-tree")
    return
end

nvim_tree.setup({
    -- 禁止内置netrw
    disable_netrw = true,
    view = {
        width = 34,
        side = "left",
        hide_root_folder = false,
        number = false,
        relativenumber = false,
        signcolumn = "yes",
        actions = {
            open_file = {
                resize_window = true,
                quit_on_open = false,
            },
        },
    },
})
