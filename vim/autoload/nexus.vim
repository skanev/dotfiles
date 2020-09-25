let s:runinfo = {}

" Test Runner callbacks {{{1
function! nexus#started(total)
  let s:runinfo.passed = 0
  let s:runinfo.failed = 0
  let s:runinfo.total = a:total
  let s:runinfo.finished = 0
endfunction

function! nexus#passed()
  let s:runinfo.passed += 1
  call s:updateStatusline()
endfunction

function! nexus#failed()
  let s:runinfo.failed += 1
  call s:updateStatusline()
endfunction

function! nexus#finished()
  let s:runinfo.finished = 1
  call s:updateStatusline()
endfunction

function! nexus#quickfix(mode, file)
  let errorformat = s:modes[a:mode].errorformat
  let old_errorformat = &errorformat

  try
    let &errorformat = errorformat
    execute 'cgetfile ' . a:file
  finally
    let &errorformat = old_errorformat
  endtry
endfunction

" Segments callbacks {{{1
function! nexus#segmentSuccess()
  if s:runinfo.failed > 0
    return ''
  endif

  if s:runinfo.finished
    return '✔'
  else
    return s:progressIndicator()
  end
endfunction

function! nexus#segmentFailure()
  if s:runinfo.failed == 0
    return ''
  endif

  if s:runinfo.finished
    return '✘'
  else
    return s:progressIndicator()
  end
endfunction

" Utility functions {{{1
function! s:resetRunInfo()
  let s:runinfo.passed = 0
  let s:runinfo.failed = 0
  let s:runinfo.total = 0
  let s:runinfo.finished = 0
endfunction

function! s:progressIndicator()
  let indicators = ['▁', '▂', '▃', '▄', '▅', '▆', '▇']
  let total = s:runinfo.total
  let ran = s:runinfo.passed + s:runinfo.failed

  if total == 0
    return ''
  elseif ran == total
    return get(indicators, -1)
  else
    let progress = float2nr(((ran * 1.0) / total) * len(indicators))
    return indicators[progress]
  endif
endfunction

function! s:updateStatusline()
  call Pl#UpdateStatusline(1)
  redrawstatus
endfunction

call s:resetRunInfo()
