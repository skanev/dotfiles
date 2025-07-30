require('config.ft').once {
  tabs = 2,
  mappings = {
    { 'n', 'Q', '<Cmd>luafile %<CR>', when = '\\<nvim/.*\\.lua$' }
  },
}
