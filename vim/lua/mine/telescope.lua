local filter = vim.tbl_filter
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local make_entry = require('telescope.make_entry')
local themes = require('telescope.themes')
local conf = require('telescope.config').values

require('telescope').load_extension('ultisnips')

-- a copy of require('telescope.builtin.internal').buffers, because it's not
-- customizable enough. mostly necessary for the mappings
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
      local actions = require('telescope.actions')
      map('i', '<C-d>', actions.delete_buffer)
      map('n', '<C-d>', actions.delete_buffer)

      return true
    end,
  }):find()
end

package.loaded['mine.telescope'] = nil

local function show_buffers_chooser()
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

return {
  buffers = show_buffers_chooser
}
