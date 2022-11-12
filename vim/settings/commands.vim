if g:env.nvim
  command! -nargs=0 SearchFiles       Telescope find_files
  command! -nargs=0 SearchBuffers     Telescope buffers
  command! -nargs=0 SearchDotfiles    lua require('telescope.builtin').find_files { cwd = vim.g.dotfiles_dir }
  command! -nargs=0 SearchVimDotfiles lua require('telescope.builtin').find_files { cwd = vim.g.dotfiles_dir .. '/vim' }<CR>

  command! -nargs=0 TreeToggle NvimTreeToggle
  command! -nargs=0 TreeFind   NvimTreeFindFile
else
  command! -nargs=0 SearchFiles   Files
  command! -nargs=0 SearchBuffers Buffers

  command! -nargs=0 TreeToggle NERDTreeToggle
  command! -nargs=0 TreeFind   NERDTreeFind

  execute "command! -nargs=0 SearchDotfiles Files " . g:dotfiles_dir
  execute "command! -nargs=0 SearchVimDotfiles Files " . g:dotfiles_dir . "/vim"
endif

let s:plugins = readdir(g:dotfiles_dir . '/vim/bundles')

function! s:open_plugin(name) abort
  tabnew
  execute "tcd " . g:dotfiles_dir . "/vim/bundles/" . a:name
  NERDTreeToggle
endfunction

function! s:open_plugin_complete(arg_lead, line, pos)
  if a:arg_lead == ""
    return s:plugins
  else
    return s:plugins->copy()->filter({ _, name -> name[0:a:arg_lead->len()-1] == a:arg_lead })
  endif
endfunction

command! -nargs=1 -complete=customlist,s:open_plugin_complete OpenPlugin call s:open_plugin(<q-args>)
