vim.g.dotfiles_dir = vim.fn.expand('~/code/personal/dotfiles')

-- TODO: Some of those need to move somewhere
vim.g.have_nerd_font = true
vim.g.env = { meta_key = 'D' }

-- Must be set before lazy is loaded

vim.g.mapleader = ','
vim.g.maplocalleader = "\\"

require('config.env')
require('config.options')
require('config.mappings')
require('config.ft')

require('config.plugins.lazy')
require('config.plugins')
require('config.appearance').setup()

require('my.trailing_whitespace').setup()
require('my.capture').setup()

vim.cmd "set runtimepath+=~/.config/nvim/plugins/explore_keys"

require('explore_keys').setup {
  ignored_mappings = {
    '<D-1>',
    '<D-2>',
    '<D-3>',
    '<D-4>',
    '<D-5>',
    '<D-6>',
    '<D-7>',
    '<D-8>',
    '<D-9>',
    '<C-Right>',
    '<C-Left>',
    '<S-Tab>',
  }
}

local vimStartup = vim.api.nvim_create_augroup('vimStartup', { clear = true })

vim.api.nvim_create_autocmd('BufReadPost', {
  group = vimStartup,
  callback = function()
    local type = vim.bo.filetype

    if type == 'commit' then return end

    local line = vim.api.nvim_buf_get_mark(0, '"')[1]

    if 0 < line and line <= vim.api.nvim_buf_line_count(0) then
      vim.cmd [[execute "normal! g`\""]]
    end
  end,
})

vim.api.nvim_set_hl(0, 'LuaSnipTabstop', { bg = '#45475a', italic = true })

local types = require("luasnip.util.types")

require("luasnip").setup({
  ext_opts = {
    [types.insertNode] = {
      visited = {
        hl_group = 'LuaSnipTabstop',
      },
      unvisited = {
        hl_group = 'LuaSnipTabstop',
      },
    },
    [types.exitNode] = {
      unvisited = {
        hl_group = 'LuaSnipTabstop',
        virt_text = {{'⫸', '@punctuation'}}
      },
    },
  }
})
