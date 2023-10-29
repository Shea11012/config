local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config

lsp_defaults.capabilities = vim.tbl_deep_extend('force',
                                                lsp_defaults.capabilities,
                                                require('cmp_nvim_lsp').default_capabilities())

function filter(client)
    local ft = vim.bo.filetype
    local n = require "null-ls"
    local s = require "null-ls.sources"
    local method = n.methods.FORMATTING
    local available_formatters = s.get_available(ft, method)

    if #available_formatters > 0 then
        return client.name == "null-ls"
    elseif client.supports_method "textDocument/formatting" then
        return true
    else
        return false
    end
end

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'LSP actions',
    callback = function(event)
        local opts = {buffer = event.buf}

        vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
        vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
        vim.keymap
            .set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
        vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>',
                       opts)
        vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>',
                       opts)
        vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
        vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>',
                       opts)
        vim.keymap.set('n', '<leader>lr', '<cmd>lua vim.lsp.buf.rename()<cr>',
                       opts)
        vim.keymap.set('n', '<leader>ft', function()
            vim.lsp.buf.format {async = true, filter = filter}
        end, opts)
        -- vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)

        vim.keymap.set('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>',
                       opts)
        vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>',
                       opts)
        vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>',
                       opts)
    end
})

require("mason").setup()
require("mason-lspconfig").setup({
    ensure_installed = vim.g.ensure_installed,
    automatic_installation = true
})
