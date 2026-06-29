-- nvim-treesitter `main` branch setup.
--
-- On `main` the plugin is just a parser/query installer. The treesitter runtime
-- (highlighting, folding, injections) lives in Neovim core, so we enable it
-- per-buffer via a FileType autocmd rather than a `highlight` module.

local mapping = require('config.helpers').mapping
local ts = require('nvim-treesitter')
local config = require('nvim-treesitter.config')

-- Parsers we always want available. Anything else is installed on demand by the
-- FileType autocmd below (the `main`-branch equivalent of `auto_install`).
local ensure_installed = {
  'bash', 'c', 'css', 'diff', 'html', 'javascript', 'json',
  'lua', 'luadoc', 'markdown', 'markdown_inline', 'query',
  'ruby', 'tsx', 'typescript', 'vim', 'vimdoc',
}

ts.install(ensure_installed)

require('nvim-treesitter-textobjects').setup {
  select = { lookahead = true },
}

-- Filetypes that should keep Vim's regex highlighting/indent: treesitter's
-- indent is unreliable for Ruby, and its highlighter relies on the legacy
-- syntax engine for some constructs.
local use_vim_indent = { ruby = true }
local keep_vim_syntax = { ruby = true }

-- Cache the available-parser list; `get_available()` fires a `User TSUpdate`
-- autocmd, so we only want to call it once.
local available
local function is_available(lang)
  if not available then
    available = {}
    for _, l in ipairs(config.get_available()) do
      available[l] = true
    end
  end
  return lang ~= nil and available[lang] == true
end

local function is_installed(lang)
  return vim.list_contains(config.get_installed(), lang)
end

local function enable_features(buf, lang)
  if not vim.api.nvim_buf_is_valid(buf) then return end

  vim.treesitter.start(buf, lang)

  local ft = vim.bo[buf].filetype
  if not keep_vim_syntax[ft] then
    vim.bo[buf].syntax = 'off'
  end
  if not use_vim_indent[ft] then
    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('my_treesitter', { clear = true }),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(vim.bo[ev.buf].filetype)
    if not is_available(lang) then return end

    if is_installed(lang) then
      enable_features(ev.buf, lang)
    else
      ts.install(lang):await(vim.schedule_wrap(function(err)
        if not err then enable_features(ev.buf, lang) end
      end))
    end
  end,
})

-- Catch the buffer we started on, whose FileType already fired before this ran.
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype ~= '' then
    local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
    if is_available(lang) and is_installed(lang) then
      enable_features(buf, lang)
    end
  end
end

require('my.incremental_selection').setup {
  init_selection = mapping('<{}-u>'),
  node_incremental = mapping('<{}-u>'),
  node_decremental = mapping('<{}-U>'),
}

local swap = require('nvim-treesitter-textobjects.swap')
vim.keymap.set('n', '<C-h>', function() swap.swap_next('@parameter.inner') end, { desc = 'Swap parameter with next' })
vim.keymap.set('n', '<C-l>', function() swap.swap_previous('@parameter.inner') end, { desc = 'Swap parameter with previous' })
