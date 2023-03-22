local status, lsp = pcall(require, 'lsp-zero')
if not status then
    vim.notify("not found lsp-zero")
    return
end

lsp.preset({
    name = 'minimal',
    set_lsp_keymaps = true,
    manage_nvim_cmp = true,
    suggest_lsp_server = false
})

lsp.ensure_installed({'gopls', 'rust_analyzer', 'tsserver'})

lsp.setup_servers({'gopls', 'rust_analyzer', 'tsserver'})

lsp.nvim_workspace()

lsp.setup()

vim.diagnostic.config({virtual_text = true})
