-- Just an example, supposed to be placed in /lua/custom/

local M = {}

-- make sure you maintain the structure of `core/default_config.lua` here,
-- example of changing theme:

M.ui = {
    theme = "ayu-dark",
}

--vim.treesitter.require_language("cpp", "~/git/tree-sitter-cpp/libtree_sitter_cpp.rlib")

M.plugins = {
    ["neovim/nvim-lspconfig"] = {
        config = function()
          require "plugins.configs.lspconfig"
          require "custom.plugins.lspconfig"
        end,
    },
    ["williamboman/mason.nvim"] = {
        override_options = {
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
    ["L3MON4D3/LuaSnip"] = {
        override_options = {
            wants = "friendly-snippets",
            after = "nvim-cmp",
            config = function()
              require("plugins.configs.others").luasnip()
              --require("custom.snips.main").luasnip()
            end,
        },
    },
    ["danymat/neogen"] = {
        config = function()
            require('neogen').setup({ snippet_engine = "luasnip", input_after_comment = true })
        end,
        requires = "nvim-treesitter/nvim-treesitter",
    },
    ["sbdchd/neoformat"] = {},
}

M.mappings = {}

return M
