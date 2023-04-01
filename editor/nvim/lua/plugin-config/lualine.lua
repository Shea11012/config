local status, lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end

local function diff_source()
    local gitsigns = vim.b.gitsigns_status_dict
    if gitsigns then
        return {
            added = gitsigns.added,
            modified = gitsigns.changed,
            removed = gitsigns.removed
        }
    end
end

local function get_cwd()
    local cwd = vim.fn.getcwd()
    local home = os.getenv("HOME")
    if cwd:find(home, 1, true) == 1 then cwd = "~" .. cwd:sub(#home + 1) end
    return "" .. cwd
end

lualine.setup({
    options = {
        theme = "catppuccin",
        component_separators = {left = "|", right = "|"},

        section_separators = {left = "", right = ""}
    },

    sections = {
        lualine_a = {{"mode"}},
        lualine_b = {{"branch"}, {"diff", source = diff_source}},

        lualine_c = {
            "filename", {
                "lsp_progress",
                spinner_symbols = {
                    " ", " ", " ", " ", " ", " "
                }
            }
        },
        lualine_x = {
            "filesize", {
                "diagnostics",
                sources = {"nvim_diagnostic"},
                symbols = {error = "", warn = "", info = ""}
            }, {get_cwd}
        },
        lualine_y = {
            {"filetype", colored = true, icon_only = true}, {"encoding"}, {
                "fileformat",
                icons_enabled = true,
                symbols = {unix = "LF", dos = "CRLF", mac = "CR"}
            }
        },
        lualine_z = {"progress", "location"}
    },
    inactive_sections = {lualine_c = {"filename"}, lualine_x = {"location"}},
    extensions = {"nvim-tree", "toggleterm"}
})
