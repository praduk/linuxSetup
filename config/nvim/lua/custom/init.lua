-- auto command to always edit if swap file exists
vim.api.nvim_create_autocmd("SwapExists", {
  desc = 'Always Edit',
  pattern = '*',
  command = 'let v:swapchoice = "e" | echomsg "Concurrent editing"'
})

-- override default options here (core/options.lua)
