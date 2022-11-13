local characters = [[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-_=+`~{}[];:'",.\| >]]

local function inputtable(lhs)
  return characters:find(lhs:sub(1, 1)) or lhs:sub(1, 4):lower() == "<lt>"
end

local function unmap_select_mappings()
  local keymaps = {
    vim.api.nvim_get_keymap('s'),
    vim.api.nvim_buf_get_keymap(0, 's'),
  }

  for _, keymap in ipairs(keymaps) do
    for _, key in ipairs(keymap) do
      if inputtable(key.lhs) then
        local lhs = key.lhs

        if key.buffer == 0 then
          vim.keymap.del('s', lhs)
        else
          vim.keymap.del('s', lhs, { buffer = 0 })
        end
      end
    end
  end
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LuasnipInsertNodeEnter",
  callback = unmap_select_mappings,
})
