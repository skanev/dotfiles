vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  remove_keymaps = { "<Tab>" },
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
        { key = "go", action = "preview" },
        { key = "?", action = "toggle_help" },
      },
    },
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
