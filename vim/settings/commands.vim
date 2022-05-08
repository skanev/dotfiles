if g:env.nvim
  command! -nargs=0 SearchFiles       Telescope find_files
  command! -nargs=0 SearchBuffers     Telescope buffers
  command! -nargs=0 SearchDotfiles    lua require('telescope.builtin').find_files { cwd = vim.g.dotfiles_dir }
  command! -nargs=0 SearchVimDotfiles lua require('telescope.builtin').find_files { cwd = vim.g.dotfiles_dir .. '/vim' }<CR>
else
  command! -nargs=0 SearchFiles   Files
  command! -nargs=0 SearchBuffers Buffers

  execute "command! -nargs=0 SearchDotfiles Files " . g:dotfiles_dir
  execute "command! -nargs=0 SearchVimDotfiles Files " . g:dotfiles_dir . "/vim"
endif
