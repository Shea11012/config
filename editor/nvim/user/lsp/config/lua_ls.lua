return {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        globals = { "vim", "astronvim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          astronvim.install.home .. "/lua",
          astronvim.install.config .. "/lua",
        },
      },
    },
  },
}
