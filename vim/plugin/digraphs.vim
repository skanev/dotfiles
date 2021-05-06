let s:digraphs = [
  \ ['eo', 'element of', '∈'],
  \
  \ ['^0', 'to the zeroeth power', '⁰'],
  \ ['^1', 'to the first power', '¹'],
  \ ['^2', 'to the second power', '²'],
  \ ['^3', 'to the third power', '³'],
  \ ['^4', 'to the fourth power', '⁴'],
  \ ['^5', 'to the fifth power', '⁵'],
  \ ['^6', 'to the sixth power', '⁶'],
  \ ['^7', 'to the seventh power', '⁷'],
  \ ['^8', 'to the eight power', '⁸'],
  \ ['^9', 'to the ninth power', '⁹'],
  \ ['^+', 'superscript plus', '⁺'],
  \ ['^-', 'superscript minus', '⁻'],
  \ ['^n', 'nth power', 'ⁿ'],
  \ ['^i', 'ith power', 'ⁱ'],
  \
  \ ['_0', 'subscript zero', '₀'],
  \ ['_1', 'subscript one', '₁'],
  \ ['_2', 'subscript two', '₂'],
  \ ['_3', 'subscript three', '₃'],
  \ ['_4', 'subscript four', '₄'],
  \ ['_5', 'subscript five', '₅'],
  \ ['_6', 'subscript six', '₆'],
  \ ['_7', 'subscript seven', '₇'],
  \ ['_8', 'subscript eight', '₈'],
  \ ['_9', 'subscript nine', '₉'],
  \ ['_i', 'subscript i', 'ᵢ'],
  \ ['_r', 'subscript r', 'ᵣ'],
  \ ['_u', 'subscript u', 'ᵤ'],
  \ ['_v', 'subscript v', 'ᵥ'],
  \
  \ ['!=', 'not equal', '≠'],
  \ ['<=', 'less than or equal to', '≤'],
  \ ['>=', 'greather than or equal to', '≥'],
  \
  \ ['s&', 'intersection', '∩'],
  \ ['s|', 'union', '∪'],
  \
  \ ['xx', 'multiplication sign', '×'],
  \ ['/o', 'empty set', '∅'],
  \ ['--', 'horizontal line', '─'],
  \
  \ ['_[', 'left square bracket lower corner', '⎣'],
  \ ['_]', 'rigth square bracket lower corner', '⎦'],
  \ ['^[', 'left square bracket upper corner', '⎡'],
  \ ['^]', 'right square bracket upper corner', '⎤'],
  \
  \ ['->', 'rightwards arrow', '→'],
  \ ['=>', 'double rightwards arrow', '⇒'],
  \
  \ ['nl', 'null', '␀'],
  \
  \ ['-n', 'en dash', '–'],
  \ ['-m', 'em dash', '—'],
  \
  \ ['^o', 'degrees', '°'],
  \ ['ph', 'placeholder', '␣'],
  \
  \ ['3.', 'ellipsis', '…'],
\ ]


function! s:InstallDigraphs()
  for [chars, name, symbol] in s:digraphs
    execute "digraph " . escape(chars, '|') . " " . char2nr(symbol)
  endfor
endfunction

function! s:DisplayDigraphs()
  for [chars, name, symbol] in s:digraphs
    echo symbol . ": " . chars . " (" . name . ")"
  endfor
endfunction

function! s:ReplaceDigraph(digraph)
  for [chars, name, symbol] in s:digraphs
    if chars == a:digraph
      return symbol
    endif
  endfor
  return a:digraph
endfunction

function! s:DigraphReplacementCommand()
  let pattern = '\V' . join(map(copy(s:digraphs), 'escape(v:val[0], "\\/")'), '\|')
  let replacement = '\=<SID>ReplaceDigraph(submatch(0))'
  return '%s/'.pattern.'/'.replacement.'/gce'
endfunction

command! ReplaceDigraphs execute s:DigraphReplacementCommand()
command! DisplayDigraphs call s:DisplayDigraphs()

call s:InstallDigraphs()
