function! s#system(command)
  let oldshell = &shell
  set shell=/bin/bash
  let result = system(a:command)
  let &shell=oldshell
  return result
endfunction

" Returns all the matches of a pattern in a given text
"
"   s#matches('(foo bar)', '\k\+') -> ['foo', 'bar']
"
function! s#matches(text, pattern) abort
  let results = []
  let pos = 0

  while v:true
    let [m, _, pos] = matchstrpos(a:text, a:pattern, pos)
    if pos == -1 | break | endif
    call add(results, m)
  endwhile

  return results
endfunction

" Flatmaps a list
"
"   [1, 2]->s#flatmap({_, k -> [k, k]}) -> [1, 1, 2, 2]
"
function! s#flatmap(list, function) abort
  let result = []
  for item in a:list
    call extend(result, a:function(item))
  endfor
  return result
endfunction

" Removes a list from another list
"
"   [1, 2, 3, 4]->s#without([1, 3]) -> [2, 4]
"
function! s#without(list, other) abort
  let elements = {}
  for e in a:other | let elements[e] = v:true | endfor
  return a:list->filter({_, e -> !elements->get(e) })
endfunction
