-- example file i.e lua/custom/init.lua
-- load your options globals, autocmds here or anything .__.
-- you can even override default options here (core/options.lua)

vim.api.nvim_create_autocmd("SwapExists", {
  desc = 'Always Edit',
  pattern = '*',
  command = 'let v:swapchoice = "e"'
})
