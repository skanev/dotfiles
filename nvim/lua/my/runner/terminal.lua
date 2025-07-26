local M = {}

local report_error = require('my.runner.utils').report_error

local function start(command, opts)
  opts = vim.tbl_extend('force', {
    autodelete = true,
    autoclose = true,
  }, opts or {})

  local view = vim.fn.winsaveview()

  local height = math.floor((vim.o.lines - 3) * 0.3)

  vim.cmd("botright " .. height .. "new")

  local bufnr = vim.fn.bufnr()
  local win_id = vim.fn.win_getid()

  vim.b[bufnr].runner_terminal = true

  vim.fn.jobstart(command, {
    term = true,
    on_exit = function(_, code)
      if not vim.api.nvim_buf_is_valid(bufnr) then
        return
      end

      vim.api.nvim_set_option_value('modifiable', true, { buf = bufnr })

      vim.fn.timer_start(20, function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

        local i = #lines
        while i > 1 do
          if lines[i] == '' or lines[i]:match("^%[Process exited %d+%]$") then
            i = i - 1
          else
            break
          end
        end

        vim.api.nvim_buf_set_lines(bufnr, i, -1, false, {})
      end)

      if code == 0 and opts.autoclose then
        vim.fn.timer_start(3000, function()
          if not vim.api.nvim_buf_is_valid(bufnr) then return end

          if not vim.api.nvim_win_is_valid(win_id) or vim.api.nvim_get_current_win() == win_id then
            return
          end

          vim.api.nvim_win_close(win_id, false)
          vim.fn.winrestview(view)
        end)
      end
    end
  })

  if opts.autodelete then
    vim.bo.bufhidden = 'delete'
  end

  vim.o.number = false

  vim.cmd('wincmd p')
end

local function runner_buffers()
  local results = {}

  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[bufnr].buftype == 'terminal' and vim.b[bufnr].runner_terminal then
      table.insert(results, bufnr)
    end
  end

  return results
end

local function delete_runner_buffers()
  for _, bufnr in ipairs(runner_buffers()) do
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_delete(bufnr, { force = true })
    end
  end
end

local function run(command, opts)
  local bufnrs = runner_buffers()

  if #bufnrs == 1 then
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == bufnrs[1] then
        vim.api.nvim_win_close(win, true)
        return
      end
    end
  end

  delete_runner_buffers()

  start(command, opts)
end

vim.api.nvim_create_user_command('RunnerLastOutput', function()
  local buffers = runner_buffers()

  if #buffers == 0 then report_error('runner: cannot find the a buffer with the output of the last run')
  elseif #buffers == 1 then vim.api.nvim_set_current_buf(buffers[1])
  else report_error('runner: found multiple buffers somehow')
  end
end, { nargs = 0 })

M.target = {
  available = function() return true end,
  execute = function(command) run(command, { autodelete = false }) end,
}

return M
