-- vim:foldmethod=marker
local loaded = false
if package.loaded['telescope'] then loaded = true end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local themes = require('telescope.themes')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local action_layout = require('telescope.actions.layout')
local entry_display = require('telescope.pickers.entry_display')
local telescope = require('telescope')

telescope.load_extension('luasnip')

local function meta(key)
  return string.format('<%s-%s>', vim.g.env.meta_key, key)
end

-- Clear defaults when hitting reloading this file, otherwise they stick.
if loaded then
  print('Resetting telescope defaults')
  require('telescope.config').clear_defaults()
  require('telescope.config').set_defaults()
end

--{{{Custom actions
local my_actions = {
  jump_to_command = function(prompt_bufnr)
    local function find_command_location(name)
      local output = vim.fn['s#capture_vim_command']('verbose command ' .. name)
      local lines = vim.split(output, "\n", true)

      for i = 1, #lines do
        if lines[i]:sub(4, 4) == ' ' and lines[i]:sub(5, #lines[i]):match('^(%S+)') == name and i < #lines then
          local next_line = lines[i + 1]
          local path, line = next_line:match("^\tLast set from (.*) line (%d+)")

          if path ~= nil then
            return path, line
          end
        end
      end

      return nil
    end

    local selection = action_state.get_selected_entry()
    local name = selection.value.name

    local path, line = find_command_location(name)
    if path ~= nil then
      actions.close(prompt_bufnr)
      vim.cmd("e " .. path)
      vim.cmd(line)
    else
      print("Could not find where " .. name .. " is defined")
    end
  end,
  jump_to_key = function(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    local function find_key_location(lhs, mode)
      local output = vim.fn['s#capture_vim_command']('verbose ' .. mode .. 'map ' .. lhs)
      local lines = vim.split(output, "\n", true)

      for i = 1, #lines do
        if lines[i]:sub(3, 3) == ' ' and lines[i]:sub(4, #lines[i]):match('^(%S+)') == lhs and i < #lines then
          local next_line = lines[i + 1]
          local path, line = next_line:match("^\tLast set from (.*) line (%d+)")

          if path ~= nil then
            return path, line
          end
        end
      end

      return nil
    end

    local lhs = selection.value.lhs
    local mode = selection.value.mode

    local path, line = find_key_location(lhs, mode)
    if path ~= nil then
      actions.close(prompt_bufnr)
      vim.cmd("e " .. path)
      vim.cmd(line)
    else
      print("Could not find where " .. lhs .. " is defined")
    end
  end,
}
--}}}

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-->'] = actions.which_key,
        [meta('p')] = action_layout.toggle_preview,
      },
      n = {
        [meta('p')] = action_layout.toggle_preview,
        [meta('P')] = action_layout.cycle_layout_next,
        ['<C-c>'] = actions.close,
      }
    },
    layout_strategy = 'flex',
    sorting_strategy = 'ascending',
    layout_config = {
      flex = {
        flip_columns = 190,
      },
      vertical = {
        prompt_position = "top",
      },
    },
  },
  pickers = {
    keymaps = {
      show_plug = false,
      mappings = {
        i = { [ '<C-o>' ] = my_actions.jump_to_key },
        n = { [ '<C-o>' ] = my_actions.jump_to_key },
      },
    },
    find_files = {
      preview = {
        hide_on_startup = true,
      }
    },
    commands = {
      mappings = {
        i = { [ '<C-o>' ] = my_actions.jump_to_command },
        n = { [ '<C-o>' ] = my_actions.jump_to_command }
      }
    },
    buffers = themes.get_dropdown {
      --borderchars = {
        --{ '─', '│', '─', '│', '┌', '┐', '┘', '└'},
        --prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
        --results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
        --preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      --},
      prompt_title = 'Buffers',
      layout_config = { width = 0.65 },
      --sort_lastused = true,
      hide_on_startup = true,
      mappings = {
        i = {
          ['<C-d>'] = require('telescope.actions').delete_buffer,
        },
        n = {
          ['<C-d>'] = require('telescope.actions').delete_buffer,
          ['dd'] = require('telescope.actions').delete_buffer,
          ['x'] = require('telescope.actions').delete_buffer,
        },
      },
    }
  },
}

--{{{Register custom extension helper
--- A function for easier creation of custom telescope extensions
local function register_extension(opts)
  local name = opts.name
  local picker = opts.picker
  require('telescope._extensions').manager[name] = nil
  package.loaded['telescope._extensions.' .. name] = nil
  package.loaded['telescope._extensions.' .. name] = telescope.register_extension({ exports = { [ name ] = picker } })
  telescope.load_extension(name)
end
--}}}

--{{{Telescope stalker
register_extension {
  name = 'stalker',
  picker = function(opts)
    opts = opts or {}
    print(vim.inspect(opts))
    local all = vim.json.decode(vim.fn.system('~/.scripts/mire stalker events'))
    local events = {}

    for _, event in ipairs(all) do
      if event.status == 'failure' and event.beholder ~= vim.NIL then
        table.insert(events, event)
      end
    end

    local displayer = entry_display.create {
      separator = '',
      items = {
        { width = 0.7 },
        { width = 15 },
        { width = 20 },
      }
    }

    pickers.new(themes.get_dropdown {
      prompt_title = 'Stalker',
      layout_config = { width = 0.75 },
      finder = finders.new_table {
        results = events,
        entry_maker = function(event)
          local function make_display(item)
            return displayer {
              { item.event.title, 'TelescopeResultsIdentifier' },
              { item.event.beholder, 'TelescopeResultsOperator' },
              { item.event.short_time, 'TelescopeResultsComment' },
            }
          end

          return {
            ordinal = event.title .. event.beholder,
            display = make_display,
            event = event,
          }
        end,
      },
      sorter = require('telescope.sorters').get_fzy_sorter(),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          vim.cmd("StalkerQuickfix " .. selection.event.id)
        end)

        return true
      end
    }):find()
  end
}
--}}}

--{{{Telescope my_commands
register_extension {
  name = 'my_commands',
  picker = function(opts)
    opts = opts or {}

    pickers.new(opts, {
      prompt_title = 'My commands',
      finder = finders.new_table {
        results = (function()
          local results = {}

          local my_scripts = vim.fn['s#my_scripts']()
          local sets = {
            vim.api.nvim_get_commands({}),
            vim.api.nvim_buf_get_commands(0, {}),
          }


          for _, set in ipairs(sets) do
            set[true] = nil
            for _, cmd in pairs(set) do
              if my_scripts[tostring(cmd.script_id)] ~= nil then
                table.insert(results, cmd)
              end
            end
          end

          return results
        end)(),
        entry_maker = make_entry.gen_from_commands({}),
      },
      sorter = conf.generic_sorter(opts),
      attach_mappings = function(prompt_bufnr, map)
        map('i', '<C-o>', my_actions.jump_to_command)
        map('n', '<C-o>', my_actions.jump_to_command)

        actions.select_default:replace(function()
          local selection = action_state.get_selected_entry()
          if selection == nil then
            return
          end

          actions.close(prompt_bufnr)
          local val = selection.value
          local cmd = string.format([[:%s ]], val.name)

          if val.nargs == "0" then
            vim.cmd(cmd)
          else
            vim.cmd [[stopinsert]]
            vim.fn.feedkeys(cmd)
          end
        end)

        return true
      end,
    }):find()
  end
}
--}}}

return { }
