local M = {}

---@generic T
---@param array T[]
---@param predicate fun(item: T): boolean
---@return T[]
function M.filter(array, predicate)
  local result = {}

  for _, item in ipairs(array) do
    if predicate(item) then
      table.insert(result, item)
    end
  end

  return result
end

---@generic T
---@param array T[]
---@param predicate fun(item: T): boolean
---@return number
function M.count(array, predicate)
  local result = 0

  for _, item in ipairs(array) do
    if predicate(item) then
      result = result + 1
    end
  end

  return result
end

---@generic B
---@generic A
---@param array A[]
---@param fn fun(item: A): B
---@return B[]
function M.map(array, fn)
  local result = {}

  for _, item in ipairs(array) do
    table.insert(result, fn(item))
  end

  return result
end

function M.index_by(array, fn)
  local result = {}

  for _, item in ipairs(array) do
    result[fn(item)] = item
  end

  return result
end

function M.shallow_copy(hash)
  local result = {}

  for key, value in pairs(hash) do
    result[key] = value
  end

  return result
end

function M.index_of(array, value)
  for index, item in ipairs(array) do
    if item == value then return index end
  end

  return 0
end

function M.max(array, default)
  if #array == 0 then
    return default
  end

  local current = array[1]

  for _, number in ipairs(array) do
    if number > current then
      current = number
    end
  end

  return current
end

function M.min(array, default)
  if #array == 0 then
    return default
  end

  local current = array[1]

  for _, number in ipairs(array) do
    if number < current then
      current = number
    end
  end

  return current
end

---@generic T
---@param table {[string]: T}
---@return T[]
function M.values(table)
  return vim.tbl_values(table)
end

---@generic T
---@param items T[]
---@param key_fn fun(item: T): string
---@return { [string]: T[] }
function M.group_by(items, key_fn)
  local result = {}

  for _, item in ipairs(items) do
    local key = key_fn(item)
    result[key] = result[key] or {}
    table.insert(result[key], item)
  end

  return result
end

return M
