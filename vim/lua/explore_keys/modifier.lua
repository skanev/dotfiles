---@class ek.Modifier
---@field name string
---@field image string
---@field keys string
---@field fn fun(key: string): string
---@field keys_to_seqs table<string, string>
---@field seqs_to_keys table<string, string>
local Modifier = {}

---@param opts { name: string, image: string, keys: string[], fn: function }
---@return ek.Modifier
function Modifier:new(opts)
  local instance = {
    name = opts.name,
    image = opts.image,
    keys = opts.keys,
    fn = opts.fn,

    keys_to_seqs = {},
    seqs_to_keys = {},
  }

  for _, key in ipairs(instance.keys) do
    local seq = instance.fn(key)
    seq = (seq == '<') and '<lt>' or seq
    instance.keys_to_seqs[key] = seq
    instance.seqs_to_keys[seq] = key
  end

  self.__index = self
  return setmetatable(instance, self)
end

---@param key string
---@return string
function Modifier:seq_for_key(key)
  return self.keys_to_seqs[key]
end

---@param seq string
---@return boolean
function Modifier:contains(seq)
  return not not self.seqs_to_keys[seq]
end

---@return string[]
function Modifier:mappable_seqs()
  return vim.tbl_keys(self.seqs_to_keys)
end

return Modifier
