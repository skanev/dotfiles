--
-- An example file that exercises some of nvim extmark functions.
--
-- It's a useful place to experiment with how some of the features work. When
-- loaded in a neovim buffer and puts in a few extmarks that it also
-- illustrates. Useful both as a cheatsheet and as an experimentation ground.
--
-- For best effects, just do:
--
--   :map <buffer> Q <Cmw>w<CR><Cmd>luafile %<CR>
--
-- And hit Q after every change.
--
local namespace_id = vim.api.nvim_create_namespace("testing")
vim.api.nvim_buf_clear_namespace(0, namespace_id, 0, -1)

-- Set an error highlight
vim.api.nvim_buf_set_extmark(0, namespace_id, 16, 10, {
  end_col = 15,
  hl_group = 'ErrorMsg'
})

-- Set some virtual text
vim.api.nvim_buf_set_extmark(0, namespace_id, 23, 0, {
  end_col = 15,
  virt_text = { { '  ', ''}, { 'Some virtual text', 'NonText' } },
})

-- Set some virtual text with overlay
vim.api.nvim_buf_set_extmark(0, namespace_id, 29, 32, {
  end_col = 43,
  virt_text = { { '[ select me to see ]', 'NonText' } },
  virt_text_pos = 'overlay',
  virt_text_hide = true,
})

 --Set some virtual text with overlay
vim.api.nvim_buf_set_extmark(0, namespace_id, 37, 0, {
  virt_lines = {
    { { '  OMG a virtual line', 'NonText' } },
    { { '  OMG another virtual line', 'NonText' } },
  }
})

-- Set a sign
vim.api.nvim_buf_set_extmark(0, namespace_id, 45, 0, {
  sign_text = ":)",
  sign_hl_group = 'Error',
})

-- Change the color of the number column
vim.api.nvim_buf_set_extmark(0, namespace_id, 51, 0, {
  number_hl_group = 'Function',
})

-- Change the color of cursorline in this range (seems not to work though)
vim.api.nvim_buf_set_extmark(0, namespace_id, 56, 0, {
  cursorline_hl_group = 'DiffText',
})
