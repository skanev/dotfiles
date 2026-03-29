require('nvim-treesitter').setup {
  ensure_installed = {},
}

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

vim.keymap.set('n', '<C-n>', function()
  local node = vim.treesitter.get_node()
  if node then
    local sr, sc, er, ec = node:range()
    vim.api.nvim_buf_set_mark(0, '<', sr + 1, sc, {})
    vim.api.nvim_buf_set_mark(0, '>', er + 1, ec - 1, {})
    vim.cmd('normal! gv')
  end
end, { desc = 'Start treesitter selection' })
