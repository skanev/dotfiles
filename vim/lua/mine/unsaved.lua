local function open_unsaved()
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'modified') then
      if vim.fn.getbufinfo(bufnr)[1].hidden == 1 then
        vim.cmd('$tab sbuffer ' .. bufnr)
      end
    end
  end
end

vim.api.nvim_create_user_command('OpenUnsaved', function() open_unsaved() end, { nargs = 0 })

require('mine.palette').register_command('OpenUnsaved', 'Open: Unsaved buffers in tabs')
