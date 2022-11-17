local luasnip = require("luasnip")

local function unsaved()
  local count = 0
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'modified') then
      if vim.fn.getbufinfo(bufnr)[1].hidden == 1 then
        count = count + 1
      end
    end

  end

  if count > 0 then
    return string.format("%d unsaved", count)
  else
    return ''
  end
end

local function snippets()
  if luasnip.in_snippet() then
    if vim.g.tweaks.devicons then
      return ''
    else
      return "SNIP"
    end
  else
    return ''
  end
end

local function context()
  if vim.b.context and vim.g.tweaks.devicons then
    return ' ' .. vim.b.context
  else
    return vim.b.context or ''
  end
end

-- Doesn't do anything, but I should either hide it or find an icon
local function encoding()
  if vim.o.encoding == 'utf-8' then
    return 'utf-8'
  else
    return vim.o.encoding
  end
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    --component_separators = { left = '', right = ''},
    --section_separators = { left = '', right = ''},
    component_separators = { left = '|', right = '|'},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {
      {unsaved, color = { fg = '#ff0000' } },
      encoding,
      snippets,
      context,
      'filetype',
    },
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
