let s:dirs = [g:dotfiles_dir . '/contexts/']
let g:context_folder = ''

if $DOTFILES_CONTEXTS_EXTRA != ''
  call extend(s:dirs, map(split($DOTFILES_CONTEXTS_EXTRA, ':'), 'fnamemodify(v:val, ":p")'))
end

let s:contexts = {}

function s:setup()
  for dir in s:dirs
    for detect in glob(dir . '*/detect', 0, 1)
      let glob = readfile(detect)[0]
      let pattern = glob2regpat(glob)
      let name = fnamemodify(detect, ':h:t')
      let dir = fnamemodify(detect, ':h')

      if filereadable(dir . '/buffer.vim')
        let buffer = dir . '/buffer.vim'
      else
        let buffer = ''
      end

      if filereadable(dir . '/folder.vim')
        let folder = dir . '/folder.vim'
      else
        let folder = ''
      endif

      let context = {'name': name, 'dir': dir, 'pattern': pattern, 'glob': glob, 'buffer': buffer, 'folder': folder}

      let s:contexts[name] = context
    endfor
  endfor
endfunction

function! s:establish_buffer_context() abort
  if exists('b:context_loaded') | return | end

  let b:context_loaded = 1

  let filename = expand('%:p')
  let found = []

  for context in values(s:contexts)
    if filename =~ context.pattern
      call add(found, context.name)
    endif
  endfor

  if len(found) > 2
    echoerr "Found more than one context applicable: " . join(found, ', ')
    return
  endif

  if len(found) == 0
    return
  endif

  let context = s:contexts[found[0]]

  let b:context = context.name

  if context.buffer != ''
    execute "source " . context.buffer
    execute "command! -buffer -nargs=0 Context split " .context.buffer
  endif
endfunction

call s:setup()

function! s:establish_directory_context()
  let pwd = getcwd() . '/'

  for context in values(s:contexts)
    if pwd =~ context.pattern && context.folder != ''

      " TODO Support per-window and per-tab contexts (although I doubt I will
      " use them often)

      if get(v:event, 'scope', 'global') == 'global' && get(g:, 'context_folder', '') != context.name
        execute "source " . context.folder
        let g:context_folder = context.name
      end

      return
    endif
  endfor
endfunction

call s:establish_directory_context()

augroup contexts
  autocmd!
  autocmd BufNewFile,BufRead * call s:establish_buffer_context()
  autocmd DirChanged * call s:establish_directory_context()
  autocmd User ResetCustomizations unlet! b:context | unlet! b:context_loaded
augroup END
