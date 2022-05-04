-- vim:foldmethod=marker

local filter = vim.tbl_filter
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local themes = require('telescope.themes')
local conf = require('telescope.config').values
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local entry_display = require('telescope.pickers.entry_display')
local telescope = require('telescope')

telescope.load_extension('ultisnips')

telescope.setup {
  defaults = {
    mappings = {
      i = {
        ['<C-->'] = actions.which_key
      }
    }
  },
  pickers = {
    keymaps = {
      show_plug = false
    },
    buffers = {
      prompt_title = 'Buffers',
      mappings = {
        i = {
          ['<C-d>'] = require('telescope.actions').delete_buffer
        },
        n = {
          ['<C-d>'] = require('telescope.actions').delete_buffer
        },
      },
    }
  }
}

local my_themes = {
  simple_dropdown_theme = function()
    return themes.get_dropdown({
      borderchars = {
        { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
        prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
        results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      },
      previewer = false,
      prompt_title = false,
      sort_lastused = true,
      layout_config = {
        width = 0.65
      },
    })
  end
}

local function stalker_events()
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

  pickers.new(my_themes.simple_dropdown_theme(), {
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

--package.loaded['mine.telescope'] = nil

--{{{Sample picker
--- A simple sample picker to use as a starting point for customization
local function sample()
  local displayer = entry_display.create {
    separator = "",
    items = {
      { width = 0.7 },
      { width = 15 },
      { width = 20 },
    }
  }

  pickers.new({
    finder = finders.new_table {
      results = { 'Fox', 'Bar', 'Baz' },
      --sorter = require("telescope.config").values.generic_sorter({}),
      entry_maker = function(line)
        local function make_display(item)
          return displayer {
            { item.name, 'TelescopeResultsIdentifier' },
            'rubocop',
            item.stuff
          }
        end

        return {
          ordinal = line,
          name = line,
          display = make_display,
          stuff = '13:38',
        }
      end,
    },
    sorter = require("telescope.sorters").get_fzy_sorter(),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        print(vim.inspect(selection))
      end)

      return true
    end
  }):find()
end
--}}}

--{{{ Previous custom telescope buffers
-- a copy of require('telescope.builtin.internal').buffers, because it's not
-- customizable enough. mostly necessary for the mappings.
--
-- TODO: I probably am not using anymore, see if I can delete it
---@diagnostic disable-next-line: unused-function
local function telescope_buffers(opts)
  local bufnrs = filter(function(b)
    if 1 ~= vim.fn.buflisted(b) then
      return false
    end
    -- only hide unloaded buffers if opts.show_all_buffers is false, keep them listed if true or nil
    if opts.show_all_buffers == false and not vim.api.nvim_buf_is_loaded(b) then
      return false
    end
    if opts.ignore_current_buffer and b == vim.api.nvim_get_current_buf() then
      return false
    end
    if opts.only_cwd and not string.find(vim.api.nvim_buf_get_name(b), vim.loop.cwd(), 1, true) then
      return false
    end
    return true
  end, vim.api.nvim_list_bufs())

  if not next(bufnrs) then return end

  local buffers = {}
  local default_selection_idx = 1

  for _, bufnr in ipairs(bufnrs) do
    local flag = bufnr == vim.fn.bufnr('') and '%' or (bufnr == vim.fn.bufnr('#') and '#' or ' ')

    if opts.sort_lastused and not opts.ignore_current_buffer and flag == "#" then
      default_selection_idx = 2
    end

    local element = {
      bufnr = bufnr,
      flag = flag,
      info = vim.fn.getbufinfo(bufnr)[1],
    }

    if opts.sort_lastused and (flag == "#" or flag == "%") then
      local idx = ((buffers[1] ~= nil and buffers[1].flag == "%") and 2 or 1)
      table.insert(buffers, idx, element)
    else
      table.insert(buffers, element)
    end
  end

  if not opts.bufnr_width then
    local max_bufnr = math.max(unpack(bufnrs))
    opts.bufnr_width = #tostring(max_bufnr)
  end

  pickers.new(opts, {
    prompt_title = 'Buffers',
    finder    = finders.new_table {
      results = buffers,
      entry_maker = opts.entry_maker or make_entry.gen_from_buffer(opts)
    },
    sorter = conf.generic_sorter(opts),
    default_selection_index = default_selection_idx,
    attach_mappings = function(_, map)
      map('i', '<C-d>', actions.delete_buffer)
      map('n', '<C-d>', actions.delete_buffer)

      return true
    end,
  }):find()
end

---@diagnostic disable-next-line: unused-local, unused-function
local function show_buffers_chooser_old()
  telescope_buffers(
    themes.get_dropdown({
      borderchars = {
        { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
        prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
        results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
        preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
      },
      previewer = false,
      prompt_title = false,
      sort_lastused = true,
      layout_config = {
        width = 0.65
      },
    })
  )
end
---}}}

local function show_buffers_chooser()
  require('telescope.builtin').buffers(my_themes.simple_dropdown_theme())
end

return {
  buffers = show_buffers_chooser,
  themes = my_themes,
  sample = sample,
  stalker_events = stalker_events,
}
