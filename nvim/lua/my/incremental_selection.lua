-- Treesitter incremental selection.
--
-- The nvim-treesitter `main` branch dropped the `incremental_selection` module,
-- so this is a small standalone replacement built on Neovim's core treesitter
-- API. `init_selection` selects the node under the cursor; `node_incremental`
-- grows the selection to the next larger named ancestor; `node_decremental`
-- shrinks back down the stack.

local M = {}

-- Per-buffer stack of selected nodes.
local stacks = {}

local function ranges_equal(a, b)
  local a1, a2, a3, a4 = a:range()
  local b1, b2, b3, b4 = b:range()
  return a1 == b1 and a2 == b2 and a3 == b3 and a4 == b4
end

local function select_node(node)
  local srow, scol, erow, ecol = node:range()

  -- Treesitter end columns are exclusive; visual marks are inclusive. When a
  -- node ends at column 0 of a line, back up to the end of the previous line.
  if ecol == 0 then
    erow = erow - 1
    ecol = #(vim.api.nvim_buf_get_lines(0, erow, erow + 1, true)[1] or '')
  end

  vim.fn.setpos("'<", { 0, srow + 1, scol + 1, 0 })
  vim.fn.setpos("'>", { 0, erow + 1, ecol, 0 })
  vim.cmd('normal! gv')
end

function M.init_selection()
  local buf = vim.api.nvim_get_current_buf()
  local node = vim.treesitter.get_node()
  if not node then return end
  stacks[buf] = { node }
  select_node(node)
end

function M.node_incremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = stacks[buf]
  if not stack or #stack == 0 then return M.init_selection() end

  local node = stack[#stack]
  local parent = node:parent()
  while parent and ranges_equal(parent, node) do
    parent = parent:parent()
  end

  if parent then
    table.insert(stack, parent)
    select_node(parent)
  else
    select_node(node)
  end
end

function M.node_decremental()
  local buf = vim.api.nvim_get_current_buf()
  local stack = stacks[buf]
  if not stack or #stack <= 1 then return end
  table.remove(stack)
  select_node(stack[#stack])
end

--- @param keys { init_selection: string, node_incremental: string, node_decremental: string }
function M.setup(keys)
  vim.keymap.set('n', keys.init_selection, M.init_selection, { desc = 'Treesitter: init selection' })
  vim.keymap.set('x', keys.node_incremental, M.node_incremental, { desc = 'Treesitter: increment selection' })
  vim.keymap.set('x', keys.node_decremental, M.node_decremental, { desc = 'Treesitter: decrement selection' })
end

return M
