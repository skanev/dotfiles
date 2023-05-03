vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  remove_keymaps = { "<Tab>" },
  on_attach = function(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
    vim.keymap.set('n', 'go', api.node.open.preview, opts('Open Preview'))
    vim.keymap.set('n', '?', api.tree.togge_help, opts('Help'))
  end,
  view = {
    adaptive_size = true,
  },
  renderer = {
    group_empty = true,
  },
  update_focused_file = {
    enable = false,
    update_root = true,
  },
  filters = {
    dotfiles = true,
  },
})
