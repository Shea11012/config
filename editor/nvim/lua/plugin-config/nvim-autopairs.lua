local status,autopairs = pcall(require, "nvim-autopairs")
if not status then
    vim.notify("not found nvim-autopairs")
    return
end

autopairs.setup({
    check_ts = true,
    ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
    },
})

