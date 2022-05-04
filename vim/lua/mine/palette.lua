local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local themes = require('telescope.themes')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local u = require('mine.util')

local registry = {
  commands = {}
}

function registry:register_command(command, name)
  local command_name_without_arguments = string.match(command, '^(%S+)')

  table.insert(self.commands, {
    command = command,
    name = name,
    available = function() return vim.fn.exists(':' .. command_name_without_arguments) == 2 end,
    execute = function() vim.cmd(command) end
  })
end

function registry:load_from_dotfiles(force)
  if self.dotfiles_loaded == true or force == true then
    return
  end

  self.commands = {} -- TODO Only those from dotfiles should be cleaned

  for _, parts in ipairs(vim.json.decode(vim.fn.system('~/.scripts/mire vim palette:documented'))) do
    if parts[1] == 'command' then
      registry:register_command(parts[2], parts[3])
    end
  end

  self.dotfiles_loaded = true
end

local function get_mapped_commands()
  local keymaps = {
    {
      keys = vim.api.nvim_get_keymap('n'),
      buffer_only = false,
    },
    {
      keys = vim.api.nvim_buf_get_keymap(0, 'n'),
      buffer_only = true,
    }
  }

  local result = {}

  for _, keymap in ipairs(keymaps) do
    for _, entry in ipairs(keymap.keys) do
      local name = string.match(entry.rhs, '^<Cmd>([^<]+)<CR>') or string.match(entry.rhs, '^<Cmd>([^<]+)<CR>')

      if not name then goto continue
      elseif string.match(entry.lhs, '^<Plug>') then goto continue
      elseif entry.expr == 1 then goto continue
      end

      if result[name] then
        result[name].multiple = true
        goto continue
      end

      result[name] = {
        key = entry.lhs,
        buffer = not not (entry.buffer == 1),
        command = name,
        multiple = false,
      }

      ::continue::
    end
  end

  return result
end

local function open_palette()
  registry:load_from_dotfiles()

  local mapped_commands = get_mapped_commands()
  local commands = u.filter(registry.commands, function(command)
    return command.available == nil or command.available()
  end)

  local displayer = entry_display.create {
    separator = "",
    items = {
      { width = 0.6 },
      { width = 25 },
      { width = 10 },
    }
  }

  pickers.new({}, themes.get_dropdown {
    prompt_title = 'Palette',
    layout_config = { width = 0.75 },
    finder = finders.new_table {
      results = commands,
      entry_maker = function(command)
        local function make_display(item)
          local key
          local mapping = mapped_commands[item.command]

          if not mapping then
            key = ''
          elseif mapping.multiple then
            key = { '-mult-', 'TelescopeResultsDiffDelete' }
          elseif mapping.buffer then
            key = { mapping.key, 'TelescopePreviewExecute' }
          else
            key = { mapping.key, 'TelescopeResultsVariable' }
          end
          return displayer {
            { item.name, 'TelescopeResultsIdentifier' },
            { item.command or '', 'TelescopeResultsOperator' },
            key,
          }
        end

        return {
          ordinal = command.name,
          name = command.name,
          display = make_display,
          command = command.command,
          key = command.key,
          execute = command.execute,
        }
      end,
    },
    --sorter = require("telescope.sorters").get_fzy_sorter(),
    sorter = require("telescope.config").values.generic_sorter({}),
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

vim.api.nvim_create_user_command('Palette', [[lua require('mine.palette').open()]], {})

return {
  registry = registry,
  open = open_palette,
}
