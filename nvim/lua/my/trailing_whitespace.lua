local globally_enabled = true

local function highlight()
  local enabled =
    vim.o.buftype ~= 'nofile' and
      vim.o.buftype ~= 'terminal' and
      globally_enabled and
      not vim.b.dont_highlight_trailing_whitespace

  if enabled then
    vim.cmd [[match TrailingWhitespace /\v\s+$/]]
  else
    vim.cmd [[match none]]
  end
end

local function unhighlight()
  vim.cmd [[match none]]
end

local function mode_change()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'i' or mode == 's' or mode == 'c' then
    unhighlight()
  else
    highlight()
  end
end

local function set_buffer(value)
  vim.b.dont_highlight_trailing_whitespace = not value
end

local function toggle()
  globally_enabled = not globally_enabled
end

local function strip()
  vim.cmd [[
     let pattern = @/
     %s/\s\+$//e
     let @/ = pattern
  ]]
end

local function setup()
  local group = vim.api.nvim_create_augroup('TrailingWhitespace', { clear = true })

  local function define_highlight()
    vim.api.nvim_set_hl(0, 'TrailingWhitespace', { bg = 'red' })
  end

  vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, { group = group, callback = highlight })
  vim.api.nvim_create_autocmd('ModeChanged', { group = group, callback = mode_change })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = define_highlight })

  vim.api.nvim_create_user_command('StripTrailingWhitespace', strip, { nargs = 0 })

  define_highlight()
end

return {
  toggle = toggle,
  strip = strip,
  set_buffer = set_buffer,
  setup = setup,
}
