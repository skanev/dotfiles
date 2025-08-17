local appearance = require('config.appearance')

local colorschemes = {
  'catppuccin-macchiato',
  'sonokai',
  'gruvbox',
  'dracula',
  'edge',
  'everforest',
  'jellybeans',
  'lucius',
  'OceanicNext',
  'nord',
  'tokyonight-moon',
  'neon',
}

local function cycle_colroscheme()
  local index = nil

  for i, name in ipairs(colorschemes) do
    if name == vim.g.colors_name then
      index = i
      break
    end
  end

  index = (index or 0) % #colorschemes + 1

  local colorscheme = colorschemes[index]
  vim.cmd('colorscheme ' .. colorscheme)
  vim.print(colorscheme)
end

local function reset_colorscheme()
  vim.cmd('colorscheme ' .. appearance.colorscheme)
  vim.print(appearance.colorscheme)
end

vim.keymap.set('n', '<F7>', cycle_colroscheme, { desc = 'Cycle colorscheme' })

return {
  cycle = cycle_colroscheme,
  reset = reset_colorscheme,
}
