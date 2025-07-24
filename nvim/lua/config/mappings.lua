local map = require('config.helpers').mapkey
local env = require('config.env')
--map <F1> :help skanev.txt<CR>
--map <F2> :ToggleBufExplorer<CR>

map('n', '<F3>', '<Cmd>NvimTreeToggle<CR>')
map('n', '<S-F3>', '<Cmd>NvimTreeFindFile<CR>')

--map <F4> <Cmd>AerialToggle<CR>
--map <S-F4> <Cmd>AerialNavToggle<CR>
--map <F6> <Cmd>Scratch<CR>
--map <F8> :%s/<C-r><C-w>//gc<Left><Left><Left>
--map <S-F8> :Ack <C-r><C-w><CR>
--

map('n', '<F9>', '<Cmd>nohlsearch<CR>')

map('n', '<F10>', '<Cmd>set cursorcolumn!<CR>')
map('i', '<F10>', '<C-o>:set cursorcolumn!<CR>')

local foo = 1

map('n', '<F11>', function() require('telescope.builtin').find_files({ cwd = vim.g.dotfiles_dir }) end)
map('n', '<S-F11>', function() require('telescope.builtin').find_files({ cwd = vim.g.dotfiles_dir .. '/nvim' }) end)

--map <C-]> <Plug>(fzf_tags)

-- TODO: It will be nice if BulgarianJK is restored
--imap <expr> jk BulgarianJK()
map('i', 'jk', '<Esc>', { noremap = true, silent = true })

--map <Leader>p <Plug>(SynStack)
--map <Leader>g <Cmd>copen<CR>
--nmap <Leader>j :SplitjoinJoin<CR>
--nmap <Leader>s :SplitjoinSplit<CR>
--map <Leader>?, <Cmd>ExplainLeader<CR>
--map <Leader>?m <Cmd>ExplainMeta<CR>
--map <Leader>?M <Cmd>ExplainInsertMeta<CR>
--map <Leader>?yo <Cmd>ExplainUnimpairedToggle<CR>
--map <Leader>?[ <Cmd>ExplainUnimpairedPrev<CR>
--map <Leader>?] <Cmd>ExplainUnimpairedNext<CR>

map('n', '<Tab>', '<C-w><C-w>', { noremap = true })
map('n', '<S-Tab>', '<C-w><C-W>', { noremap = true })
map('i', '<S-Tab>', '<C-v><C-i>', { noremap = true })
map('n', '<C-p>', '<C-i>', { noremap = true })
map('n', ',,', ',', { noremap = true })
map('n', '<Space>', ':', { noremap = true })
map('v', '<Space>', ':', { noremap = true })
map('n', 'Q', function() end, { noremap = true })

--nmap [c <Plug>(GitGutterPrevHunk)
--nmap ]c <Plug>(GitGutterNextHunk)
--
map('n', '[g', '<Cmd>cprev<CR>')
map('n', ']g', '<Cmd>cnext<CR>')

--nmap <silent> yoa <Cmd>ALEToggleBuffer<CR>
--nmap <silent> yog <Cmd>call <SID>ToggleGitGutter()<CR>

--nnoremap <C-h> :SidewaysLeft<CR>
--nnoremap <C-l> :SidewaysRight<CR>
map('n', '<C-k>', '<Cmd>set hlsearch!<CR>')

--nnoremap - :Switch<CR>
--cnoremap <C-c> <C-^>
--inoremap <C-c> <C-^>

--map <C-Left> :bnext<CR>
--map <C-Right> :bprevious<CR>

--map <expr> g= ':Tabularize /\V' . expand('<cWORD>') . '<CR>'

--cnoremap <expr> / <SID>cmd_mode_slash()

map('n', '<{}-f>', '<Cmd>Telescope find_files<CR>')
map('n', '<{}-j>', '<Cmd>Telescope buffers<CR>')
map('n', '<{}-k>', '<Cmd>NvimTreeToggle<CR>')
map('n', '<{}-K>', '<Cmd>NvimTreeFindFile<CR>')

--if g:env.nvim
--MapMeta m <Cmd>lua require('mine').cycle_diagnostics()<CR>
--MapMeta p <Cmd>Palette<CR>
--endif

map('n', '<{}-]>', '>>')
map('n', '<{}-[>', '<<')

map('v', '<{}-]>', '>gv')
map('v', '<{}-[>', '<gv')

--MapMeta r <Plug>(runner-run-file-or-last)
--MapMeta R <Plug>(runner-run-line)

--MapMeta l <Plug>(quickterminal)
--TMapMeta l <Plug>(quickterminal)

--if g:env.nvim
--NMapMeta e <Plug>(mine-send-text-buffer)
--VMapMeta e <Plug>(mine-send-text-selection)
--else
--MapMeta e <Plug>NexusSendBuffer
--VMapMeta e <Plug>NexusSendSelection
--endif

--MapMeta / <Plug>NERDCommenterToggle
--VMapMeta / <Plug>NERDCommenterToggle

map('n', '<{}-w>', '<Cmd>close<CR>')

if env.app == 'neovide' then
  map('n', '<{}-F>', '<Cmd>let g:neovide_fullscreen = !get(g:, "neovide_fullscreen", v:false)<CR>')
end

map('n', '<{}-s>', '<Cmd>write<CR>')
map('n', '<{}-t>', '<Cmd>tabnew<CR>')
map('n', '<{}-a>', 'ggVG')
map('n', '<{}-v>', '"+p')

map('v', '<{}-c>', '"+y')
map('i', '<{}-v>', '<C-r>+')

local change_tab

if env.tmux then
  change_tab = function (i)
    return function ()
      local tabs = vim.fn.tabpagenr('$')

      if tabs == 1 or i > tabs or vim.fn.mode() ~= 'n' then
        vim.fn.system('~/.scripts/tmux/switch-tab --of-tmux ' .. i)
      else
        vim.cmd("tabnext " .. i)
      end
    end
  end
else
  change_tab = function (i) return function() vim.cmd("tabnext " .. i) end end
end

for i = 1, 9 do
  map({'n', 'i', 'v', 'c', 'x'}, '<{}-' .. i .. '>', change_tab(i))
end

--function s:sid()
--return '<SNR>' . matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$') . '_'
--endfun

--if g:env.app == 'nvim-qt' || g:env.app == 'neovide'
--call MapMeta('nvic', '', '-', '<Cmd>call '.s:sid()."set_font('delta', -1)<CR>")
--call MapMeta('nvic', '', '=', '<Cmd>call '.s:sid()."set_font('delta', 1)<CR>")
--call MapMeta('nvic', '', '0', '<Cmd>call '.s:sid()."set_font('reset', 0)<CR>")

map('n', '<{}-0>', function() require('config.appearance').adjust_font_size(nil) end)
map('n', '<{}-->', function() require('config.appearance').adjust_font_size(-1) end)
map('n', '<{}-=>', function() require('config.appearance').adjust_font_size(1) end)
--function! s:set_font(action, number)
--if a:action == 'reset'
--let &guifont = g:appearance.font
--elseif a:action == 'delta'
--let size = matchstr(&guifont, '\d\+')
--let &guifont = substitute(&guifont, '\d\+', size + a:number, '')
--else
--throw "Unknown action: " . a:action
--end
--endfunction
--endif

--" When typing %/ it expands to the directory of the current file.

--function s:cmd_mode_slash()
--let line = getcmdline()

--if line[len(line) - 1] == '%' && line[len(line) - 2] == ' ' && getcmdtype() == ':'
--return "\<BS>" . expand('%:h') . '/'
--else
--return '/'
--endif
--endfunction
