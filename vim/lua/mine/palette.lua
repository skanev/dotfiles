local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local themes = require('telescope.themes')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local u = require('mine.util')

-- TODO: Define custom highlights for Palette
-- TODO: Use fixed width and get precise about putting args

-- Caches things
--
-- Useful to calculate things once per palette run instead of once for each
-- command.
local Interrogator = {}

function Interrogator:new()
  local instance = {
    cache = {}
  }

  self.__index = self
  return setmetatable(instance, self)
end

function Interrogator:load(key)
  if self.cache[key] == nil then
    self.cache[key] = self['_load_' .. key](self)
  end
end

function Interrogator:_ensure(key)
  return self.cache[key] or error("Expected " .. key .. " to be loaded")
end

function Interrogator:_load_command_index()
  local result = {}

  local keymaps = {
    {
      keys = vim.api.nvim_get_keymap('n'),
      buffer = false,
    },
    {
      keys = vim.api.nvim_buf_get_keymap(0, 'n'),
      buffer = true,
    }
  }

  for _, keymap in ipairs(keymaps) do
    for _, entry in ipairs(keymap.keys) do
      if entry.rhs == nil then goto continue end

      local name = string.match(entry.rhs, '^<[Cc][Mm][Dd]>([^<]+)<[Cc][Rr]>') or string.match(entry.rhs, '^:([^<]+)<[Cc][Rr]>')

      if name == nil then goto continue
      elseif string.match(entry.lhs, '^<Plug>') then goto continue
      elseif entry.expr == 1 then goto continue
      end

      if result[name] == nil then
        result[name] = {}
      end

      table.insert(result[name], {
        entry = entry,
        buffer = keymap.buffer,
      })

      ::continue::
    end
  end

  return result
end

function Interrogator:mappings_for_command(command_name)
  return self:_ensure('command_index')[command_name]
end

local OptionBuilder = {}

function OptionBuilder.mapping(name, keys)
  return {
    name = name,
    command = nil,
    mapping = keys,
    execute = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "t", true)
    end
  }
end

function OptionBuilder.custom_command(command, name)
  local command_name_without_arguments = string.match(command, '^(%S+)')

  return {
    name = name,
    command = command,
    mapping = function(interrogator)
      local mappings = interrogator:mappings_for_command(command)

      if not mappings or #mappings == 0 then return nil
      elseif #mappings > 1 then return '-mult-'
      else return mappings[1].entry.lhs
      end
    end,
    mapping_hl = function(interrogator)
      local mappings = interrogator:mappings_for_command(command)

      if not mappings or #mappings == 0 then return 'TelescopePreviewExecute'
      elseif #mappings > 1 then return 'TelescopeResultsDiffDelete'
      elseif mappings[1].buffer then return 'TelescopePreviewExecute'
      else return nil
      end
    end,
    available = function() return vim.fn.exists(':' .. command_name_without_arguments) == 2 end,
    execute = function() vim.cmd(command) end,
    needs = { 'command_index' },
  }
end

local function open_palette(opts)
  opts = opts or {}

  local width = opts.width or 110
  local prompt_title = opts.title or 'Palette'
  local options = nil

  local interrogator = Interrogator:new()

  local function calculate(value, default)
    if type(value) == 'function' then value = value(interrogator) end
    if value == nil and default ~= nil then value = default end
    return value
  end

  if vim.tbl_islist(opts) then
    options = opts
  else
    options = opts.options
  end

  options = u.filter(options, function(option)
    return option.available == nil
      or option.available == true
      or type(option.available) == 'function' and option.available()
  end)

  for _, option in ipairs(options) do
    if option.needs then
      for _, key in ipairs(option.needs) do
        interrogator:load(key)
      end
    end
  end

  local displayer = entry_display.create {
    separator = '',
    items = {
      { width = (width - 25 - 8 - 4) },
      { width = 25 },
      { width = 8 },
    }
  }

  local function make_display(item)
    return displayer {
      { item.option.name, 'TelescopeResultsIdentifier' },
      { item.option.command or '', 'TelescopeResultsOperator' },
      { calculate(item.option.mapping, ''), calculate(item.option.mapping_hl, 'TelescopeResultsVariable') },
    }
  end

  pickers.new({}, themes.get_dropdown {
    prompt_title = prompt_title,
    layout_config = { width = width },
    finder = finders.new_table {
      results = options,
      entry_maker = function(option)
        return {
          ordinal = option.name,
          name = option.name,
          option = option,
          display = make_display,
          execute = option.execute,
        }
      end,
    },
    sorter = require("telescope.sorters").get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        selection.execute()
      end)

      return true
    end
  }):find()
end

local registry = {
  dotfiles_commands = {},
  dotfiles_loaded = false,
  palettes = {},
  main_commands = {},
}

function registry:load_from_dotfiles(force)
  if self.dotfiles_loaded and force ~= true then
    return self.dotfiles_commands
  end

  self.dotfiles_commands = {}

  for _, parts in ipairs(vim.json.decode(vim.fn.system('~/.scripts/mire vim palette:documented'))) do
    if parts[1] == 'command' then
      table.insert(self.dotfiles_commands, OptionBuilder.custom_command(parts[2], parts[3]))
    end
  end

  self.dotfiles_loaded = true

  return self.dotfiles_commands
end

function registry:open(palette)
  local options = self.palettes[palette] or error("Pallete not found: " .. palette)
  open_palette(options)
end

function registry:register_palette(name, opts)
  self.palettes[name] = opts
end

local function open_main_palette()
  local commands = {}
  vim.list_extend(commands, registry:load_from_dotfiles())
  vim.list_extend(commands, registry.main_commands)

  open_palette {
    title = 'Palette',
    options = commands,
  }
end

local function register_keys_cheatsheet(opts)
  registry:register_palette(opts.key, {
    title = opts.title,
    options = u.map(opts.keys, function(items) return OptionBuilder.mapping(items[1], items[2]) end),
  })

  table.insert(registry.main_commands, OptionBuilder.custom_command("Palette " .. opts.key, "Palette: " .. opts.title))
end

vim.api.nvim_create_user_command(
  'Palette',
  function(opts)
    if opts.args == '' then
      open_main_palette()
    else
      registry:open(opts.args)
    end
  end,
  {
    nargs = '?',
    complete = function(_, line)
      local options = vim.tbl_keys(registry.palettes)
      local parts = vim.split(line, '%s+')

      if #parts == 1 then
        return options
      elseif #parts == 2 then
        return vim.tbl_filter(function(val) return vim.startswith(val, parts[2]) end, options)
      end
    end,
  }
)

register_keys_cheatsheet {
  key = 'folds',
  title = 'Folds',
  keys = {
    { 'Fold: Open current fold', 'zo' },
    { 'Fold: Open all folds under cursor', 'zO' },
    { 'Fold: Close current fold', 'zc' },
    { 'Fold: Close all folds under cursor', 'zC' },
    { 'Fold: Fold more', 'zm' },
    { 'Fold: Fold all', 'zM' },
    { 'Fold: Fold less', 'zr' },
    { 'Fold: Unfold all', 'zR' },
    { 'Fold: Toggle current fold', 'za' },
    { 'Fold: Toggle folding', 'zi' },
    { 'Fold: Enable folding', 'zN' },
    { 'Fold: Disable folding', 'zn' },
    { 'Fold: Undo manual folding (w/o current line)', 'zx' },
    { 'Fold: Undo manual folding (incl current line)', 'zX' },
    { 'Fold: Start of current fold', '[z' },
    { 'Fold: End of current fold', ']z' },
    { 'Fold: Next fold', 'zj' },
    { 'Fold: Previous fold', 'zk' },
    { 'Fold: Show lines', ':set foldcolumn=5<CR>' },
    { 'Fold: Hide lines', ':set foldcolumn&<CR>' },
  }
}

return {
  registry = registry,
  open_main = open_main_palette,
  open = function(key) registry:open(key) end,
}
