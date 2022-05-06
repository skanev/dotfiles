local M = {}

function M.filter(array, predicate)
  local result = {}

  for _, item in ipairs(array) do
    if predicate(item) then
      table.insert(result, item)
    end
  end

  return result
end

function M.map(array, fn)
  local result = {}

  for _, item in ipairs(array) do
    table.insert(result, fn(item))
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

return M
