function _G.put(...)
  for _, item in ipairs({...}) do
    print(vim.inspect(item))
  end
end
