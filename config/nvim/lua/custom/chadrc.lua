-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
  theme = "ayu-dark",
}

M.plugins = {
  user = require "custom.plugins",
  override = {
    ["williamboman/mason.nvim"] = {
      ensure_installed = {
        -- lua stuff
        "lua-language-server",
        "stylua",

        -- web dev
        "css-lsp",
        "html-lsp",
        "typescript-language-server",
        "deno",
        "emmet-ls",
        "json-lsp",

        -- Software Developemnt
        "clangd",
        "clang-format",
        "cmake-language-server",
        "bash-language-server",
        "yaml-language-server",
        "python-lsp-server",
        "rust-analyzer",

        -- Analysis
        "julia-lsp",
        -- "metamath-zero-lsp",

        -- Documentation
        "ltex-ls",
        "texlab",
        "dot-language-server",

        -- shell
        "shfmt",
        "shellcheck",
      },
    },
  },
}

return M
