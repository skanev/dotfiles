local function list_contains(list, name)
  for _, item in ipairs(list) do
    if item == name then
      return true
    end
  end

  return false
end

return {
  list_contains = list_contains
}
