local rules = {
  { { app = 'nvim', tmux = true }, { colorscheme = 'gruvbox' } },
  { { app = 'nvim' }, { colorscheme = 'OceanicNext' } },
  { { app = 'neovide' }, { colorscheme = 'dracula', line = 3, font = "FiraCode Nerd Font Mono:h15" } },
}

local matchers = { 'app', 'tmux' }
local settings = { 'colorscheme', 'line', 'font' }

local function matches(env, rule)
  for _, key in ipairs(matchers) do
    if rule[1][key] and env[key] ~= rule[1][key] then
      return false
    end
  end

  return true
end

local config = {}

local env = require('config.env')

for _, rule in ipairs(rules) do
  if matches(env, rule) then
    for _, setting in ipairs(settings) do
      if rule[2][setting] then
        config[setting] = config[setting] or rule[2][setting]
      end
    end
  end
end

local function setup()
  if env.app == 'neovide' then
    vim.g.neovide_cursor_animation_length = 0.04
    vim.g.neovide_scroll_animation_length = 0.08
    vim.g.neovide_floating_blur_amount_x = 4.0
    vim.g.neovide_floating_blur_amount_y = 3.0
    vim.g.neovide_frame = 0
    vim.g.neovide_padding_top = 0
    vim.g.neovide_floating_shadow = true
    vim.g.neovide_floating_z_height = 10
    vim.g.neovide_light_angle_degrees = 45
    vim.g.neovide_light_radius = 5
    vim.g.neovide_floating_corner_radius = 0.4
    vim.g.neovide_position_animation_length = 0.15
    vim.g.neovide_opacity = 1
    vim.g.neovide_normal_opacity = 1
  end

  if config.colorscheme then
    vim.cmd('colorscheme ' .. config.colorscheme)
  end

  if config.font then
    vim.opt.guifont = config.font
  end

  if config.line then
    vim.opt.linespace = config.line
  end
end

local function adjust_font_size(adjustment)
  if env.app == 'nvim' then
    vim.cmd "echoerr 'Adjusting font size is not supported in terminal Neovim.'"
    return
  end

  if adjustment == nil then
    vim.opt.guifont = config.font
  else
    vim.opt.guifont = vim.o.guifont:gsub("%d+", function(size)
      local new_size = math.max(8, tonumber(size) + adjustment)
      return tostring(new_size)
    end)
  end
end

return {
  setup = setup,
  adjust_font_size = adjust_font_size,
}
