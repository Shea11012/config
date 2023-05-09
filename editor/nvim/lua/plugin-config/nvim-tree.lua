local status, nvim_tree = pcall(require, "nvim-tree")
if not status then
    vim.notify("not found nvim-tree")
    return
end

nvim_tree.setup({
    sync_root_with_cwd = true,
    view = {
        width = 34,
        side = "left",
        hide_root_folder = false,
        number = false,
        relativenumber = false,
        signcolumn = "yes"
    },
    update_focused_file = {enable = true, update_root = true},
    actions = {
        use_system_clipboard = true,
        change_dir = {enable = true, global = false}
    },
    git = {ignore = false}
})
