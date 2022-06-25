local u = require('mine.util')
local strings = require('plenary.strings')
local keyset = require('explore_keys.keyset')
local drawing = require('explore_keys.drawing')
local KeyboardImage = require('explore_keys.keyboard_image')
local config = require('explore_keys.config')

local highlights = {
  keys = {
    default = 'KeyBrowserKeyDefault',
    global  = 'KeyBrowserKeyGlobal',
    buffer  = 'KeyBrowserKeyBuffer',
    mixed   = 'KeyBrowserKeyMixed',
    error   = 'KeyBrowserKeyError',
  }
}

---@param text string
---@param size number
---@return string
local function pad(text, size)
  text = strings.truncate(text, size)
  text = text .. string.rep(' ', size - vim.fn.strdisplaywidth(text))
  return text
end

---@diagnostic disable-next-line: unused-function, unused-local
local function common_prefix(texts)
  if #texts == 0 then
    return ""
  end

  local sample = texts[1]
  local max_length = #sample

  for _, string in ipairs(texts) do
    for j = 1, #sample do
      if string:sub(j, j) ~= sample:sub(j, j) then
        max_length = math.min(max_length, j - 1)
      end
    end
  end

  return sample:sub(1, max_length)
end

local visuals = {
  [' '] = '␣',
  ['<lt>'] = '<',
}

local function display_sequence(seq)
  return visuals[seq] or seq
end

---@class ek.Explorer
---@field modifier ek.Modifier
---@field workspace_start number
---@field input string[]
---@field keyset ek.Keyset
---@field keyboard_image ek.KeyboardImage
---@field ignored_mappings table<string, true|nil>
---@field modifiers ek.Modifier[]
---@field positions table<string, { row: number, col: number }>
local Explorer = {}

function Explorer:new()
  local modifiers = config.configuration.modifiers
  local modifier = modifiers[1]

  local instance = {
    modifiers = modifiers,
    positions = {},
    workspace_start = 0,
    mappings = {},
    input = {},
    keyset = keyset.Keyset:new(),
    modifier = modifier,
    keyboard_image = KeyboardImage:new(modifier.image),
    ignored_mappings = {},
  }

  self.__index = self

  for _, mapping in ipairs(config.configuration.ignored_mappings) do
    instance.ignored_mappings[mapping] = true
  end

  return setmetatable(instance, self)
end

function Explorer:nsid()
  return vim.api.nvim_create_namespace('explain_keys')
end

function Explorer:open_window()
  self:_setup_window()
  self:_setup_input_keybindings()
  self:_render_top_keyboard()
end

function Explorer:_render_top_keyboard()
  local lines = vim.split(self.keyboard_image.image:gsub('space', '     '), "\n")
  local padding = math.floor(math.max(0, vim.fn.winwidth(self.winid) - vim.fn.strdisplaywidth(lines[1])) / 2)

  lines = u.map(lines, function(line) return (" "):rep(padding) .. line end)

  table.insert(lines, ('─'):rep(vim.fn.winwidth(self.winid)))
  table.insert(lines, '')

  self.workspace_start = #lines + 1

  self.positions = {}

  for char, pos in pairs(self.keyboard_image.key_positions) do
    self.positions[char] = { row = pos.row, col = pos.col + padding }
  end

  self.space_position = {
    row = self.keyboard_image.special_positions.space.row,
    col = self.keyboard_image.special_positions.space.col + padding,
  }

  vim.api.nvim_buf_set_lines(self.bufid, 0, -1, true, lines)
end

function Explorer:_setup_window()
  self.bufid = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_buf_set_option(self.bufid, 'bufhidden', 'wipe')

  local width = vim.o.columns - 20
  local height = vim.o.lines - 10

  width = math.min(width, vim.o.columns - 6)
  height = math.min(height, vim.o.lines - 4)

  self.winid = vim.api.nvim_open_win(self.bufid, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height - 2) / 2),
    col = math.floor((vim.o.columns - width - 2) / 2),
    style = 'minimal',
    border = 'rounded',
  })

  vim.api.nvim_win_set_option(self.winid, 'winhl', 'Normal:KeyBrowserBackground,FloatBorder:KeyBrowserBorder')

  local autocmds = {}

  local function clear_autocmds()
    for _, auid in ipairs(autocmds) do
      vim.api.nvim_del_autocmd(auid)
    end
  end

  table.insert(autocmds, vim.api.nvim_create_autocmd({ 'BufLeave' }, {
    buffer = self.bufid,
    callback = function()
      vim.api.nvim_win_close(self.winid, false)
      clear_autocmds()
    end
  }))

  table.insert(autocmds, vim.api.nvim_create_autocmd({ 'TermEnter' }, {
    buffer = self.bufid,
    callback = function()
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-\\><C-n>', true, false, true), 'n', false)
    end
  }))

  vim.keymap.set('n', '<Esc>', '<Cmd>close<CR>', { buffer = self.bufid, nowait = true, noremap = true })
end

function Explorer:_setup_input_keybindings()
  for _, modifier in ipairs(self.modifiers) do
    for _, seq in ipairs(modifier:mappable_seqs()) do
      vim.keymap.set('n', seq, function() self:push_input(seq, true) end, { buffer = self.bufid, nowait = true })
    end
  end

  vim.keymap.set('n', '<C-c>', function() self:close() end, { buffer = self.bufid, nowait = true, noremap = true })
  vim.keymap.set('n', '<Esc>', function() self:close() end, { buffer = self.bufid, nowait = true, noremap = true })

  vim.keymap.set('n', '<BS>',    function() self:pop_input() end,        { buffer = self.bufid })
  vim.keymap.set('n', '<Left>',  function() self:cycle_modifier(-1) end, { buffer = self.bufid })
  vim.keymap.set('n', '<Right>', function() self:cycle_modifier(1) end,  { buffer = self.bufid })
  vim.keymap.set('n', '<Tab>',   function() self:cycle_modifier(1) end,  { buffer = self.bufid })

  vim.keymap.set('n', '<Enter>',   function() self:run_current_mapping() end,  { buffer = self.bufid })
  vim.keymap.set('n', '<C-Enter>', function() self:open_current_mapping() end, { buffer = self.bufid })
end

function Explorer:render()
  vim.api.nvim_buf_clear_namespace(self.bufid, self:nsid(), 0, -1)
  vim.api.nvim_buf_set_lines(self.bufid, self.workspace_start - 1, -1, true, {})

  local prefix = table.concat(self.input)
  local analysis = self.keyset:analyse(prefix)

  if self.keyset:has_mapping(prefix) then
    self:_render_current_mapping()
  end

  self:_render_highlight_keys(analysis.continuations)
  self:_render_continuations(analysis.continuations)

  if self.space_position then
    local current_sequence = table.concat(u.map(self.input, display_sequence))

    local row = self.space_position.row - 1
    local col = self.space_position.col - math.floor(#current_sequence / 2)

    vim.api.nvim_buf_set_extmark(self.bufid, self:nsid(), row, col, {
      virt_text = { { current_sequence, 'KeyBrowserCurrentInput' } },
      virt_text_pos = 'overlay',
      virt_text_hide = true,
    })
  end

  vim.api.nvim_buf_set_extmark(self.bufid, self:nsid(), self.workspace_start - 4, 0, {
    virt_text = { { self.modifier.name, 'KeyBrowserAccent' } },
    virt_text_pos = 'eol',
    virt_text_hide = true,
  })
end

function Explorer:cycle_modifier(delta)
  local index = 1

  for i, modifier in ipairs(self.modifiers) do
    if self.modifier == modifier then
      index = i
      break
    end
  end

  local count = #self.modifiers
  local new_index = (index - 1 + delta + count) % count + 1

  self.modifier = self.modifiers[new_index]
  self.keyboard_image = KeyboardImage:new(self.modifier.image)

  self:_render_top_keyboard()
  self:render()
end

---Highlights the keys in the keyboard ontop
---@param continuations table<string, ek.Keyset.Continuation>
function Explorer:_render_highlight_keys(continuations)
  for _, char in ipairs(self.keyboard_image:available_keys()) do
    local lhs = self.modifier:seq_for_key(char)
    local continuation = continuations[lhs]
    local pos = self.positions[char]

    if continuation and pos then
      local highlight = highlights.keys[continuation:scope()] or highlights.keys.error

      vim.api.nvim_buf_set_extmark(self.bufid, self:nsid(), pos.row - 1, pos.col - 1, {
        hl_group = highlight,
        end_col = pos.col,
      })
    end
  end
end

function Explorer:_render_current_mapping()
  local lhs = table.concat(self.input)
  local mappings = self.keyset:mappings_for(lhs)
  local drawer = drawing.WindowDrawer:new { winid = self.winid, nsid = self:nsid(), bufid = self.bufid }

  local hierarchy = {
    { name = 'In buffer', hl = 'KeyBrowserKeyBuffer',  mapping = mappings.buffer },
    { name = 'Global',    hl = 'KeyBrowserKeyGlobal',  mapping = mappings.global },
    { name = 'Built-in',  hl = 'KeyBrowserKeyDefault', mapping = mappings.default },
  }

  local rendered_a_mapping = false
  ---@cast hierarchy { name: string, hl: string, mapping: ek.Mapping | nil }[]
  for _, level in ipairs(hierarchy) do
    if level.mapping then
      if rendered_a_mapping then
        drawer:put_line('')
      end

      drawer:put_lines {
        { '  ', { 'Mapping:     ', 'KeyBrowserText' }, { level.mapping.lhs, level.hl } },
        { '  ', { 'Definition:  ', 'KeyBrowserText' }, level.mapping:formatted_definition() },
      }

      if level.mapping.desc or level.mapping.doc then
        drawer:put_line { '  ', { 'Description: ', 'KeyBrowserText' }, { level.mapping.desc or level.mapping.doc, 'KeyBrowserText' } }
      end

      if level.mapping.location then

        drawer:put_line {
          '  ',
          { 'Location:    ', 'KeyBrowserText' },
          { level.mapping.location.file .. ':' .. level.mapping.location.line, 'KeyBrowserText' }
        }
      end

      rendered_a_mapping = true
    end
  end

  drawer:put_separator()
end

---@param continuations_map table<string, ek.Keyset.Continuation>
function Explorer:_render_continuations(continuations_map)
  local drawer = drawing.WindowDrawer:new { winid = self.winid, nsid = self:nsid(), bufid = self.bufid }

  local continuations = u.values(continuations_map)
  continuations = u.filter(continuations, function(c)
    return u.count(c.items, function(item) return not self.ignored_mappings[item.mapping.lhs] end) > 0
  end)
  continuations = u.filter(continuations, function(c) return c.key ~= '<SNR>' and c.key ~= '<Plug>' end)

  table.sort(continuations, function(a, b)
    return a.key < b.key
  end)

  ---@type table<string, ek.Keyset.Continuation[]>
  local groups = u.group_by(continuations, function(c)
    if c:scope() == 'default' then
      return 'default'
    elseif self.modifier:contains(c.key) then
      return 'primary'
    else
      return 'secondary'
    end
  end)

  local key_width = u.max(u.map(continuations, function (e) return vim.fn.strdisplaywidth(e.key) end))

  local rendered_a_section = false

  ---@type string[]
  local section_names = { 'primary', 'secondary', 'default' }

  for _, section_name in ipairs(section_names) do
    if groups[section_name] and #groups[section_name] > 0 then
      if rendered_a_section then
        drawer:put_separator { padding = 2 }
      end

      drawer:draw_columns {
        columns = 2,
        items = groups[section_name],
        render = function(continuation)
          ---@cast continuation ek.Keyset.Continuation
          return drawing.rich_text {
            { pad(display_sequence(continuation.key), key_width), highlights.keys[continuation:scope()] or highlights.keys.error },
            '  ',
            continuation:formatted_description()
          }
        end
      }

      rendered_a_section = true
    end
  end
end

function Explorer:push_input(key, only_when_viable)
  if only_when_viable and not self.keyset:has_mapping_prefix(table.concat(self.input) .. key) then
    return
  end
  self.input[#self.input + 1] = key
  self:render()
end

function Explorer:pop_input()
  if #self.input > 0 then
    self.input[#self.input] = nil
  end
  self:render()
end

function Explorer:run_current_mapping()
  local input = table.concat(self.input)
  if self.keyset.mappings[input] then
    self:close()
    vim.api.nvim_input(input)
  end
end

function Explorer:open_current_mapping()
  local input = table.concat(self.input)
  if self.keyset.mappings[input] then
    local mapping = self.keyset.mappings[input]
    if mapping.location then
      self:close()
      vim.cmd 'tabnew'
      vim.cmd('edit ' .. mapping.location.file)
      vim.cmd(tostring(mapping.location.line))
    end
  end
end

function Explorer:close()
  vim.api.nvim_win_close(self.winid, true)
end

function Explorer:obtain_mappings(target_buffnr, mode)
  mode = mode or 'n'
  self.keyset = keyset.Keyset.for_buffer(target_buffnr, {
    expand_plug_prefixes = true,
    find_locations = true,
    mode = mode,
  })
end

function Explorer:feed(seqs)
  local left = seqs

  while left and left ~= '' do
    local first
    first, left = keyset.split_mapping(left)
    self:push_input(first)
  end
end

return {
  Explorer = Explorer
}
