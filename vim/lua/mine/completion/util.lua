local cmp = require('cmp')

local function establish_source(name, source)
  for _, registered in pairs(cmp.core.sources) do
    if registered.name == name then
      cmp.unregister_source(registered.id)
    end
  end

  return cmp.register_source(name, source)
end

return {
  establish_source = establish_source
}
