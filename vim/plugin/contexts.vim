let s:dirs = [g:dotfiles_dir . '/contexts/']
let g:context_folder = ''

if $DOTFILES_CONTEXTS_EXTRA != ''
  call extend(s:dirs, map(split($DOTFILES_CONTEXTS_EXTRA, ':'), 'fnamemodify(v:val, ":p")'))
end

let s:contexts = {}

function! s:extract_segment(tag, path) abort
  let result = []
  let within = 0

  for line in readfile(a:path)
    if line == a:tag       | let within = 1
    elseif line == '@@end' | let within = 0
    elseif within          | call add(result, line)
    endif
  endfor

  return result
endfunction

function! s:execute_vimscript(lines) abort
  let path = tempname()
  call writefile(a:lines, path)
  execute "source " . path
  call delete(path)
endfunction

function! s:establish_buffer_context() abort
  if exists('b:context_loaded') | return | end

  let b:context_loaded = 1

  let filename = expand('%:p')
  let found = []

  for context in values(s:contexts)
    if s:file_matches_patterns(filename, context.patterns)
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
    if context.single
      call s:extract_segment('@@vim.buffer', context.buffer)->s:execute_vimscript()
    else
      execute "source " . context.buffer
    endif
    execute "command! -buffer -nargs=0 Context split " .context.buffer
  endif
endfunction

function! s:file_matches_patterns(filename, patterns) abort
  for pattern in a:patterns
    if a:filename =~ pattern
      return 1
    endif
  endfor

  return 0
endfunction

function s:setup() abort
  for dir in s:dirs
    for detect in glob(dir . '*/detect', 0, 1)
      let lines = readfile(detect)
      if len(lines) == 0
        continue
      endif

      let name = fnamemodify(detect, ':h:t')
      let dir = fnamemodify(detect, ':h')
      let patterns = lines->copy()->map({ _, line -> line->glob2regpat() })

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

      let context = {'name': name, 'patterns': patterns, 'buffer': buffer, 'folder': folder, 'single': 0}

      let s:contexts[name] = context
    endfor
  endfor

  for dir in s:dirs
    for path in glob(dir . '*', 0, 1)
      if isdirectory(path)
        continue
      endif

      let name = fnamemodify(path, ':t')
      let lines = readfile(path)

      let patterns = lines
            \->copy()
            \->filter({_, line -> line =~ '^@@detect ' })
            \->map({_, line -> line->substitute('^@@detect ', '', '')->glob2regpat() })

      if len(patterns) == 0
        continue
      endif

      if lines->count('@@vim.buffer') > 0
        let buffer = path
      else
        let buffer = ''
      endif

      if lines->count('@@vim.folder') > 0
        let folder = path
      else
        let folder = ''
      endif

      let context = {'name': name, 'patterns': patterns, 'buffer': path, 'folder': path, 'single': 1}

      let s:contexts[name] = context
    endfor
  endfor
endfunction

function! s:establish_directory_context()
  let pwd = getcwd() . '/'

  for context in values(s:contexts)
    if s:file_matches_patterns(pwd, context.patterns) && context.folder != ''

      " TODO Support per-window and per-tab contexts (although I doubt I will
      " use them often)
      if get(v:event, 'scope', 'global') == 'global' && get(g:, 'context_folder', '') != context.name
        if context.single
          call s:extract_segment('@@vim.folder', context.folder)->s:execute_vimscript()
        else
          execute "source " . context.folder
        endif
        let g:context_folder = context.name
      end

      return
    endif
  endfor
endfunction

call s:setup()
call s:establish_directory_context()

augroup contexts
  autocmd!
  autocmd BufNewFile,BufRead * call s:establish_buffer_context()
  autocmd DirChanged * call s:establish_directory_context()
  autocmd User ResetCustomizations unlet! b:context | unlet! b:context_loaded
augroup END
