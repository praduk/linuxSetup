--------------- DEFAULT OPTIONS --------------
-- override default options here (core/options.lua)


------------------- PLUGINS ------------------

--- VIMTEX

-- Viewer options: One may configure the viewer either by specifying a built-in
-- viewer method:
vim.g.vimtex_view_method = 'zathura'

-- -- Or with a generic interface:
-- let g:vimtex_view_general_viewer = 'okular'
-- let g:vimtex_view_general_options = '--unique file:@pdf\#src:@line@tex'

-- VimTeX uses latexmk as the default compiler backend. If you use it, which is
-- strongly recommended, you probably don't need to configure anything. If you
-- want another compiler backend, you can change it as follows. The list of
-- supported backends and further explanation is provided in the documentation,
-- see ":help vimtex-compiler".
-- vim.g.vimtex_compiler_method = 'latexrun'

-- Most VimTeX mappings rely on localleader and this can be changed with the
-- following line. The default is usually fine and is the symbol "\".
vim.maplocalleader = ","

--- Tab Spacing
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

---------------- Some Keybindings  ---------------------
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<Leader>df", ":lua require('neogen').generate()<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>dc", ":lua require('neogen').generate({type=\"class\"})<CR>", opts)
vim.api.nvim_set_keymap("n", "<Leader>dt", ":lua require('neogen').generate({type=\"type\"})<CR>", opts)

---------------- Clang Format ------------------------
vim.cmd(
[[
let g:neoformat_cpp_clangformat = {
    \ 'exe': 'clang-format',
    \ 'args': ['--style="{IndentWidth: 4}"']
\}
let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_enabled_c = ['clangformat']
noremap <Leader>fd :Neoformat<CR>
]])

---------------- Snippets ---------------------
-- require 'custom/snips/general'
-- dofile('lua/custom/snips/general.lua')
-- vim.g.luasnippets_path = "~/.config/nvim/lua/custom/snips"

---------------- AUTO COMMANDS ---------------

-- auto command to always edit if swap file exists
vim.api.nvim_create_autocmd("SwapExists", {
  desc = 'Always Edit',
  pattern = '*',
  command = 'let v:swapchoice = "e" | echomsg "Concurrent editing"'
})
