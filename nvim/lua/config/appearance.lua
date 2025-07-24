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
  if config.colorscheme then
    vim.cmd('colorscheme ' .. config.colorscheme)
  end

  if config.font then
    vim.print(config.font)
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

adjust_font_size()

return {
  setup = setup,
  adjust_font_size = adjust_font_size,
}
