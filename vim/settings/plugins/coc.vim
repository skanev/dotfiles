" I'm not sure I am going to end up using CoC. It's strange and massively
" weird to configure. It's also hard to monkeypatch because of all the
" JavaScript.
"
" Still, I'm uncertain what else to go for – YCM seems great, but it's Vim8
" only. A bunch of other things require either a nightly nvim, for which I'm
" not ready yet, or have other issues. I'll probably consider deoplete, but
" I'm not there yet.
"
" Still, let's have this for a while and enjoy it while it lasts.
"
" Also, I try not to keep mappings here, but it's hard :)

let g:UltiSnipsExpandTrigger       = '<Plug>UltiExpand'
let g:UltiSnipsListSnippets        = '<Plug>UltiList'
let g:UltiSnipsJumpForwardTrigger  = '<C-j>'
let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

" Don't let enwise clobber <CR> without asking
let g:endwise_no_mappings = v:true
let g:coc_config_home		  = '~/.vim'

function! s:setup()
  if g:tweaks.devicons
    call coc#config("suggest.completionItemKindLabels", {
        \ "keyword":       "\uf1de",
        \ "variable":      "\ue79b",
        \ "value":         "\uf89f",
        \ "operator":      "\u03a8",
        \ "constructor":   "\uf0ad",
        \ "function":      "\u0192",
        \ "reference":     "\ufa46",
        \ "constant":      "\uf8fe",
        \ "method":        "\uf09a",
        \ "struct":        "\ufb44",
        \ "class":         "\uf0e8",
        \ "interface":     "\uf417",
        \ "text":          "\ue612",
        \ "enum":          "\uf435",
        \ "enumMember":    "\uf02b",
        \ "module":        "\uf40d",
        \ "color":         "\ue22b",
        \ "property":      "\ue624",
        \ "field":         "\uf9be",
        \ "unit":          "\uf475",
        \ "event":         "\ufacd",
        \ "file":          "\uf723",
        \ "folder":        "\uf114",
        \ "snippet":       "\ue60b",
        \ "typeParameter": "\uf728",
        \ "default":       "\uf29c"
        \})
  endif
endfunction

autocmd User CocNvimInit call s:setup()

" Treat ultisnips very differently than CoC
let g:in_ultisnips = 0
autocmd! User UltiSnipsEnterFirstSnippet
autocmd  User UltiSnipsEnterFirstSnippet let g:in_ultisnips = 1
autocmd! User UltiSnipsExitLastSnippet
autocmd  User UltiSnipsExitLastSnippet   let g:in_ultisnips = 0

inoremap <silent><expr> <TAB>
    \ coc#jumpable() ? "<C-R>=coc#rpc#request('snippetNext', [])<cr>" :
    \ g:in_ultisnips \|\| UltiSnips#CanExpandSnippet() ? "\<C-r>=UltiSnips#ExpandSnippetOrJump()<cr>" :
    \ pumvisible() ? coc#_select_confirm() :
    \ <SID>check_back_space() ? "\<Tab>" :
    \ coc#refresh()

inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

inoremap <silent><expr> <c-space> coc#refresh()

inoremap <expr> <Plug>CustomCocCR complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
imap            <CR>              <Plug>CustomCocCR<Plug>DiscretionaryEnd

nmap <silent> [d <Plug>(coc-diagnostic-prev)
nmap <silent> ]d <Plug>(coc-diagnostic-next)

nmap <silent> gD <Plug>(coc-definition)
nmap <silent> gT <Plug>(coc-type-definition)
nmap <silent> gM <Plug>(coc-implementation)
nmap <silent> gR <Plug>(coc-references)

nnoremap <silent> K <Cmd>call <SID>show_documentation()<CR>

augroup mygroup
  autocmd!
  autocmd FileType typescript,json    setlocal formatexpr=CocAction('formatSelected') " Setup formatexpr specified filetype(s).
  autocmd User     CocJumpPlaceholder call CocActionAsync('showSignatureHelp')        " Update signature help on jump placeholder.
augroup end

nnoremap <silent><nowait> <Leader>fa  <Cmd>CocList diagnostics<cr>
nnoremap <silent><nowait> <Leader>fc  <Cmd>CocList commands<cr>
nnoremap <silent><nowait> <Leader>fe  <Cmd>CocList extensions<cr>
nnoremap <silent><nowait> <Leader>fo  <Cmd>CocList outline<cr>
nnoremap <silent><nowait> <Leader>fs  <Cmd>CocList -I symbols<cr>
nnoremap <silent><nowait> <Leader>fj  <Cmd>CocNext<CR>
nnoremap <silent><nowait> <Leader>fk  <Cmd>CocPrev<CR>
nnoremap <silent><nowait> <Leader>fp  <Cmd>CocListResume<CR>
nmap                      <leader>fr  <Plug>(coc-rename)
xmap                      <leader>ff  <Plug>(coc-format-selected)
nmap                      <leader>ff  <Plug>(coc-format-selected)
nmap                      <leader>ffl <Plug>(coc-fix-current)

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <Leader>a  <Plug>(coc-codeaction-selected)
nmap <Leader>a  <Plug>(coc-codeaction-selected)
nmap <Leader>ac <Plug>(coc-codeaction)

xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

MapMeta u <Plug>(coc-range-select)
XMapMeta u <Plug>(coc-range-select)

command! -nargs=0 Format :call CocAction('format')                                     " Add `:Format` command to format current buffer.
command! -nargs=? Fold   :call CocAction('fold', <f-args>)                             " Add `:Fold` command to fold current buffer.
command! -nargs=0 OR     :call CocAction('runCommand', 'editor.action.organizeImport') " Add `:OR` command for organize imports of the current buffer.

function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
