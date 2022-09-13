-- custom.plugins.lspconfig
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local utils = require("core.utils")

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "clangd", "yamlls", "julials", "bashls", "jsonls", "pylsp", "cmake", "dotls", "rust_analyzer", "texlab", "ltex", "tsserver"}


for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end
