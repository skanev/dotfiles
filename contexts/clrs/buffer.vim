let b:patterns = {}
let b:patterns['\v^.*<(\d+)/(\d+)/(\d+)\.test\.(py|c)$']    = 'rake test:exercise\\[\1,\2,\3\\]'
let b:patterns['\v^.*<(\d+)/(\d+)/(\d+)\.run\.(py|c)$']     = 'rake run:exercise\\[\1,\2,\3\\]'
let b:patterns['\v^.*<(\d+)/problems/(\d+)\.test\.(py|c)$'] = 'rake test:problem\\[\1,\2\\]'
let b:patterns['\v^.*<(\d+)/problems/(\d+)\.run\.(py|c)$']  = 'rake run:problem\\[\1,\2\\]'

let b:runner_mode = {}
function! b:runner_mode.command(action)
  for [pattern, sub] in items(b:patterns)
    if matchstr(expand('%'), pattern) != ''
      return substitute(expand('%'), pattern, sub, '')
    endif
  endfor
endfunction
