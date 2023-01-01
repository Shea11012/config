local status,lualine = pcall(require, "lualine")
if not status then
    vim.notify("not found lualine")
    return
end

lualine.setup({
    options = {
        theme = "tokyonight",
        component_separators = {
            left = "|",
            right = "|",
        },

        section_separators = {
            left = " ",
            right = "",
        },
        globalstatus = true,
    },

    extensions = { "nvim-tree" },

    sections = {
    lualine_c = {
      "filename",
      {
        "lsp_progress",
        spinner_symbols = { " ", " ", " ", " ", " ", " " },
      },
    },
    lualine_x = {
      "filesize",
      {
        "fileformat",
        -- symbols = {
        --   unix = '', -- e712
        --   dos = '', -- e70f
        --   mac = '', -- e711
        -- },
        symbols = {
          unix = "LF",
          dos = "CRLF",
          mac = "CR",
        },
      },
      "encoding",
      "filetype",
    },
  },
})
