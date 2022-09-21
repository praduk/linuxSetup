-- custom.plugins.lspconfig
local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local utils = require("core.utils")

local lspconfig = require "lspconfig"
local servers = { "html", "cssls", "yamlls", "julials", "bashls", "jsonls", "pylsp", "cmake", "dotls", "rust_analyzer", "texlab", "ltex", "tsserver"}


for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
  }
end

lspconfig["clangd"].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = {"clangd","--background-index","--suggest-missing-includes","--clang-tidy=false"},
}
