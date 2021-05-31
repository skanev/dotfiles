" COMPLETION WITH NVIM, COMPE, ULTISNIPS AND VSNIPS
"
" This is the outcome of a lot of blood and sweat. It sets up completion in a
" coc.nvim-less, deoplete-less nvim world that's (1) to my taste, (2) supports
" UltiSnips in some form, (3) gets the snippet completions from LSP and (4) I
" can put some user completion functions in it afterwards for retro-style
" completion. Remarks:
"
" - I don't use vsnips per se, but they are needed by compe in order to do the
"   LSP snippets, as far as I can tell (e.g. when completing the name of a
"   function along with its arguments)
"
" - UltiSnips works, but I'm not using it in anger, so I'm certain it will
"   find a way to break some time soon.
"
" - I'm not too excted about the as-you-type completion, but it's
"   occasionally useful. Hence, I've added a mechansim to turn it on and off.
"
" - It also works with endwise

" compe needs this, otherwise it just gets weird

set completeopt=menuone,noselect

" The come configuration. It's here, because I call compe#setup() often, and
" this ignores g:compe

let s:configuration = {
      \ 'enabled': v:true,
      \ 'autocomplete': v:true,
      \ 'debug': v:false,
      \ 'min_length': 1,
      \ 'preselect': 'enable',
      \ 'throttle_time': 80,
      \ 'source_timeout': 200,
      \ 'incomplete_delay': 400,
      \ 'max_abbr_width': 100,
      \ 'max_kind_width': 100,
      \ 'max_menu_width': 100,
      \ 'documentation': v:true,
      \ 'source': {
      \   'path': v:true,
      \   'buffer': v:true,
      \   'calc': v:true,
      \   'nvim_lsp': v:true,
      \   'nvim_lua': v:false,
      \   'vsnip': v:false,
      \   'omni': v:false,
      \   'ultisnips': v:true,
      \ }
      \}

let g:compe = s:configuration

" Tweak endwise

let g:endwise_no_mappings = 1

" Tweak Ultisnips

" Don't let it steal <Tab> away from us
let g:UltiSnipsExpandTrigger = "<Plug>(ultisnips-trigger)"
let g:UltiSnipsMappingsToIgnore = ['select-mode-jump']

" Track whether there is a current snippet or not
let g:currently_in_ultisnips = 0
augroup completion_and_ultisnips
  autocmd!
  autocmd  User UltiSnipsEnterFirstSnippet let g:currently_in_ultisnips = 1
  autocmd  User UltiSnipsExitLastSnippet   let g:currently_in_ultisnips = 0
augroup END

" A bunch of helper functions to, well, help

" Returns the current as-you-type setting, called 'autocomplete' in compe
function! s:is_as_you_type()
  return luaeval('require("compe.config").get().autocomplete')
endfunction

" Sets a specific value for compe.autocomplete
function! s:setup_as_you_type(enabled)
  let config = copy(s:configuration)
  let config.autocomplete = a:enabled ? v:true : v:false

  call compe#setup(config)
endfunction

" Toggle as-you-type
function! s:toggle_as_you_type()
  call s:setup_as_you_type(!s:is_as_you_type())
endfunction

" Behavior when pressing tab. It's kinda involved
function! s:tab()
  if UltiSnips#CanExpandSnippet()
    return "\<C-r>=UltiSnips#ExpandSnippet()\<cr>"
  elseif pumvisible() && complete_info(['mode']).mode == 'eval'
    return compe#confirm({ 'select': 1, 'keys': "\<Plug>(new-line)", 'mode': 'n' })
  elseif g:currently_in_ultisnips
    return "\<C-r>=UltiSnips#ExpandSnippetOrJump()\<cr>"
  elseif pumvisible()
    return "\<C-n>"
  elseif getline('.')[0:col('.') - 1] =~ '^\s*$'
    return "\<Plug>(insert-tab)"
  else
    return "\<C-n>\<C-n>"
  endif
endfunction

" Use <C-a><Space> to turn as-you-type on and off. Will likely decide to do it
" in insert mode, so let's have an insert mode mapping.
call IMapLeader('imap', v:false, '<Space>', '<Cmd> call '.expand('<SID>').'toggle_as_you_type()<CR>')

inoremap <Plug>(new-line) <CR>

" We need to insert a tab in a imap, so here's a cheesy way to be able to.
inoremap <Plug>(insert-tab) <Tab>

" Le tab mapping
imap <expr> <Tab> <SID>tab()

" Snippet jumping back and forth in select mode
snoremap <Plug>(select-mode-jump-forwards) <Esc><Cmd>call UltiSnips#JumpForwards()<CR>
snoremap <Plug>(select-mode-jump-backwards) <Esc><Cmd>call UltiSnips#JumpBackwards()<CR>
smap <Tab> <Plug>(select-mode-jump-forwards)
smap <S-Tab> <Plug>(select-mode-jump-backwards)

" Compe mappings

inoremap <silent><expr> <C-Space> compe#complete()
imap     <silent><expr> <CR>      compe#confirm('<CR>') . "\<Plug>DiscretionaryEnd"
inoremap <silent><expr> <C-y>     compe#confirm('<C-y>')
inoremap <silent><expr> <C-e>     compe#close('<C-e>')

" I should eventually map those, but (1) I don't want <C-d> stolen and (2) I
" haven't needed to scroll the docs just yet.
"inoremap <silent><expr> <C-f>     compe#scroll({ 'delta': +4 })
"inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
