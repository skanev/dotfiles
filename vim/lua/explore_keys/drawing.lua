local u = require('mine.util')
local strings = require('plenary.strings')

---@class ek.RichTextChunk
---@field text string
---@field highlight string | nil
---@field width number
---@field length number
local RichTextChunk = {}

function RichTextChunk:new(text, highlight)
  local instance = { text = text, highlight = highlight }
  instance.width = strings.strdisplaywidth(instance.text)
  instance.length = #instance.text
  self.__index = self
  return setmetatable(instance, self)
end

function RichTextChunk:dup()
  return RichTextChunk:new(self.text, self.highlight)
end

---@class ek.RichText
---@field chunks ek.RichTextChunk[]
local RichText = {}

function RichText:new(chunks)
  local instance = { chunks = chunks }
  self.__index = self
  return setmetatable(instance, self)
end

---@param args any
---@return ek.RichText
function RichText.build(args)
  local chunks = {}

  args = vim.tbl_islist(args) and args or { args }

  for _, part in ipairs(args) do
    if type(part) == 'string' then
      table.insert(chunks, RichTextChunk:new(part))
    elseif type(part) == 'table' and getmetatable(part) == RichText then
      for _, chunk in ipairs(part.chunks) do
        table.insert(chunks, chunk)
      end
    elseif type(part) == 'table' and #part == 2 then
      table.insert(chunks, RichTextChunk:new(part[1], part[2]))
    else
      error("Unknown bit: " .. vim.inspect(part))
    end
  end

  return RichText:new(chunks)
end

function RichText:plain_text()
  return table.concat(u.map(self.chunks, function(c) return c.text end))
end

function RichText:pad(size)
  ---@type ek.RichTextChunk[]
  local chunks = {}
  local left = size
  local added = 0

  for _, chunk in ipairs(self.chunks) do
    added = added + 1
    left = left - chunk.width

    if chunk.width > 0 then
      table.insert(chunks, chunk)
    end

    if left <= 0 then
      break
    end
  end

  if left > 0 then
    table.insert(chunks, RichTextChunk:new(string.rep(' ', left)))
  elseif left < 0 then
    local last = chunks[#chunks]
    local truncated = strings.truncate(last.text, last.width + left)
    chunks[#chunks] = RichTextChunk:new(truncated, last.highlight)
  elseif left == 0 and added ~= #self.chunks then
    local last = chunks[#chunks]
    local truncated = strings.truncate(last.text .. " ", last.width)
    chunks[#chunks] = RichTextChunk:new(truncated, last.highlight)
  end

  return RichText:new(chunks)
end

local function rich_text(args)
  return RichText.build(args)
end

---@class ek.WindowDrawer
---@field winid window
---@field bufid buffer
---@field nsid number
local WindowDrawer = {}

---@param opts { nsid: number, winid: window, bufid: buffer }
---@return ek.WindowDrawer
function WindowDrawer:new(opts)
  local instance = { nsid = opts.nsid, bufid = opts.bufid, winid = opts.winid }
  self.__index = self
  return setmetatable(instance, self)
end

---@generic T
---@params opts { items: T[], render: (fun(item: T): any) }
function WindowDrawer:draw_columns(opts)
  local items = opts.items
  local render = opts.render

  if #items == 0 then
    return
  end

  local item_count = #items
  local columns = opts.columns or 3
  local column_padding = opts.padding or 2

  local window_width = vim.fn.winwidth(self.winid)
  local column_width = math.max(0, (window_width - column_padding) / columns) - column_padding
  local padding = string.rep(" ", column_padding)

  local lines = {}

  local step = math.ceil(item_count / columns)

  for i = 0, step - 1 do
    local line = {}

    for j = 0, columns - 1 do
      local item = items[i + j * step + 1]

      if item then
        local left = column_width
        local rich = RichText.build(render(item, column_width))

        table.insert(line, padding)
        table.insert(line, rich:pad(left))
      end
    end
    table.insert(lines, line)
  end

  self:put_lines(lines)
end

function WindowDrawer:put_line(colored_line)
  self:put_lines { RichText.build(colored_line) }
end

function WindowDrawer:put_lines(colored_lines)
  local start = vim.api.nvim_buf_line_count(self.bufid)
  ---@type ek.RichText[]
  local lines = u.map(colored_lines, RichText.build)

  vim.api.nvim_buf_set_lines(self.bufid, start, -1, true, u.map(lines, function(t) return t:plain_text() end))

  for index, line in ipairs(lines) do
    local col = 0

    for _, chunk in ipairs(line.chunks) do
      if chunk.highlight then
        vim.api.nvim_buf_set_extmark(self.bufid, self.nsid, start + index - 1, col, {
          hl_group = chunk.highlight,
          end_col = col + chunk.length,
        })
      end

      col = col + chunk.length
    end
  end
end

---@param opts? { padding?: number }
function WindowDrawer:put_separator(opts)
  opts = opts or {}

  local padding = opts.padding or 0
  local window_width = vim.fn.winwidth(self.winid)

  self:put_lines {
    '',
    (' '):rep(padding) .. ('─'):rep(window_width - 2 * padding),
    '',
  }
end

return {
  rich_text = rich_text,
  RichText = RichText,
  RichTextChunk = RichTextChunk,
  WindowDrawer = WindowDrawer,
}
