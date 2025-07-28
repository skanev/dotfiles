local normal_mode_mappings = {
  -- basic movement
  ["h"] = 'go left',
  ["j"] = 'go down',
  ["k"] = 'go up',
  ["l"] = 'go right',
  ["<C-P>"] = 'go up',
  ["<C-H>"] = 'go left',
  ["<C-J>"] = 'go down',
  ["<C-N>"] = 'go down',
  ["<C-M>"] = 'go down',

  -- word movement
  ["w"] = 'go to start of next word',
  ["e"] = 'go to end of next word',
  ["b"] = 'go to start of previous word',
  ["ge"] = 'go to end of previous word',
  ["W"] = 'go to start of next WORD',
  ["E"] = 'go to end of next WORD',
  ["B"] = 'go to start of previous WORD',
  ["gE"] = 'go to end of previous WORD',

  -- line movement
  ["+"] = 'go to next line (first non-blank)',
  ["-"] = 'go to previous line (first non-blank)',
  ["0"] = 'go to first char of line',
  ["|"] = 'go to first column of line',
  ["$"] = 'go to end of line',
  ["{"] = 'go back a paragraph',
  ["}"] = 'go forward a paragraph',
  ["("] = 'go back a sentence',
  [")"] = 'go forward a sentence',
  ["^"] = 'go to first non-blank character of line',
  ["gM"] = 'go to middle of line',
  ["_"] = 'go to first non-blank character of line',
  ["g_"] = 'go to last non-blank character of line',

  -- line wrap movement
  ["g$"] = 'go to last character of line (line wrap)',
  ["g0"] = 'go to first character of line (line wrap)',
  ["g^"] = 'go to first non-blank character on line (line wrap)',
  ["gj"] = 'go to next line (line wrap)',
  ["gk"] = 'go to previous line (line wrap)',
  ["gm"] = 'go to middle of line (line wrap)',

  -- scrolling
  ["<C-Y>"] = 'scroll up a line',
  ["<C-E>"] = 'scroll down a line',
  ["<C-B>"] = 'scroll up a page',
  ["<C-F>"] = 'scroll down a page',
  ["<C-U>"] = 'scroll up half-screen',
  ["<C-D>"] = 'scroll down half-screen',
  ["zH"] = 'scroll half-screen to the right',
  ["zL"] = 'scroll half-screen to the left',
  ["zh"] = 'scroll screen left',
  ["zl"] = 'scroll screen right',
  ["zs"] = 'scroll screen right w/o moving cursor',
  ["ze"] = 'scroll screen left w/o moving cursor',

  -- recenter screen
  ["z-"] = 'redraw current line at bottom of window',
  ["zb"] = 'redraw current line at bottom of window leaving cursor',
  ["z."] = 'redraw current line at center of window',
  ["zz"] = 'redraw current line at center of window leaving cursor',
  ["z<CR>"] = 'redraw current line at top of window',
  ["zt"] = 'redraw current line at top of window leaving cursor',
  ["z^"] = 'scroll up, w/ startofline',
  ["z+"] = 'scroll down, w/ startofline',

  -- file movement
  ["G"] = 'go to end of file',
  ["gg"] = 'go to first line',
  ["go"] = 'go to n-th byte of buffer (default: 0)',

  -- screen movement
  ["H"] = 'go to top of screen',
  ["M"] = 'go to middle of screen',
  ["L"] = 'go to bottom of screen',

  -- f and t
  [","] = 'repeat f/F/t/T in opposite direction',
  [";"] = 'repeat last f/F/t/T',
  ["f"] = 'find char forward',
  ["t"] = 'till character forward',
  ["F"] = 'find char backward',
  ["T"] = 'till character backward',

  -- jumping
  ["<C-I>"] = 'jump forwards',
  ["<C-O>"] = 'jump backward',
  ["<C-T>"] = 'jump to previous tag',
  ["<C-]>"] = 'jump to tag under cursor',
  ["<Tab>"] = 'go to newer entry in jump list',
  ["g]"] = 'like <C-]> but with :tselect',
  ["gf"] = 'open file under cursor',
  ["gF"] = 'open file under cursor and go to line number',
  ["gd"] = 'go to local declaration',
  ["gD"] = 'go to global declaration',
  ["g<C-]>"] = 'tjump to tag under cursor',
  ["<C-^>"] = 'edit alternate file',
  ["<C-6>"] = 'edit alternate file',

  -- change list
  ['g;'] = 'go to previous position in change list',
  ['g,'] = 'go to next position in change list',

  -- visual mode
  ["V"] = 'visual line mode',
  ["v"] = 'visual mode',
  ["<C-V>"] = 'visual block mode',
  ["gv"] = 'select previous visual selection',
  ["<C-Q>"] = 'visal block mode (for GUIs because <C-v> may be paste)',

  -- select mode
  ["gh"] = 'select mode (like v)',
  ["gH"] = 'select mode (like V)',
  ["g<C-H>"] = 'select mode (like <C-v>)',
  ["gV"] = 'avoid automatic reselection after select mode mapping',

  -- insert mode
  ["i"] = 'insert',
  ["I"] = 'insert to beginning of line',
  ["gi"] = 'insert where last exited insert mode',
  ["gI"] = 'insert to begining of line (before indent)',
  ["a"] = 'append after cursor',
  ["A"] = 'append to end of line',
  ["o"] = 'open a new line below',
  ["O"] = 'open a new line above',

  -- change
  ["c"] = 'change to {motion}',
  ["cc"] = 'change line',
  ["C"] = 'change to end of line',
  ["s"] = 'change character',
  ["S"] = 'change line',

  -- delete
  ["d"] = 'delete to {motion}',
  ["dd"] = 'delete line',
  ["D"] = 'delete to end of line',
  ["x"] = 'delete character',
  ["X"] = 'delete character before cursor',
  ["<Del>"] = 'delete character under cursor',

  -- yank
  ["y"] = 'yank to {motion}',
  ["yy"] = 'yank a line',
  ["Y"] = 'yank to end of line (nvim)',
  ["zy"] = 'yank w/o trailing whitespace (for blocks)',

  -- paste
  ["p"] = 'put text after cursor',
  ["P"] = 'put before cursor',
  ["gp"] = 'like p, but leave cursor just after new text',
  ["gP"] = 'like P, but leave cursor just after new text',
  ["zp"] = 'like p, but w/o trailing whitespace in block',
  ["zP"] = 'like P, but w/o trailing whitespace in block',

  -- replace
  ["r"] = 'replace character under cursor',
  ["R"] = 'replace mode',
  ["gr"] = 'replace character w/o affecting layout (r but for <Tab>)',
  ["gR"] = 'visual replace mode (for <Tab>)',


  -- increment and decrement
  ["<C-A>"] = 'increase number after cursor',
  ["<C-X>"] = 'decrease number after cursor',

  -- repeat
  ["."] = 'repeat last change',

  -- marks
  ["`"] = 'go to {mark}',
  ["'"] = 'go to {mark} line',
  ["g`"] = 'go to {mark} (keeping jumps)',
  ["g'"] = 'go to {mark} line (keeping jumps)',
  ["m"] = 'mark current position with {mark}',

  -- indent
  [">"] = 'indent lines {motion}',
  [">>"] = 'indent lines',
  ["<lt>"] = 'deindent lines {motion}',
  ["<lt><lt>"] = 'dedent line',

  -- registers
  ['"'] = 'select {register}',

  -- undo and redo
  ["U"] = 'undo changes on one line',
  ["u"] = 'undo',
  ["g-"] = 'undo (via :earlier)',
  ["g+"] = 'redo (via :later)',
  ["<C-R>"] = 'redo',

  -- macros
  ["q"] = 'record a macro in {register}',
  ["@"] = 'execute macro {register}',
  ["@@"] = 'repeat last macro',
  ["Q"] = 'replay last macro (nvim) or Ex mode (vim)',

  -- joining lines
  ["J"] = 'join next line',
  ["gJ"] = 'join line (w/o space)',

  -- exiting
  ["ZQ"] = 'same as :q!',
  ["ZZ"] = 'save and exit',

  -- case switching
  ["~"] = 'switch case under cursor',
  ["gu"] = 'lowercase to {motion}',
  ["gU"] = 'uppercase to {motion}',
  ["g~"] = 'switch case to {motion}',
  ["g?"] = 'rot13 encode to {motion}',
  ['g?g?'] = 'rot13 encode current line',

  -- show stuff under cursor
  ["ga"] = 'show ASCII value under cursor',
  ["g8"] = 'show UTF8 sequence of character under cursor',
  ["g<C-G>"] = 'show cursor position info',
  ["<C-G>"] = 'show current filname and cursor position',

  -- diff
  ['do'] = 'same as :diffget',
  ['dp'] = 'same as :diffput',

  -- searching
  ['/'] = 'search forward',
  ['?'] = 'search backward',
  ['*'] = 'search forward for word under cursor',
  ['#'] = 'search backward for word under cursor',
  ['n'] = 'go to next search match',
  ['N'] = 'go to previous search match',
  ['gn'] = 'go to next match and visually select it',
  ['gN'] = 'go to previous match and visually select it',
  ["g*"] = 'like *, but without \\< and \\>',
  ["g#"] = 'like #, but without \\< and \\>',
  ["<C-C>"] = 'interrupt a search',

  -- miscellaneous
  ["<Space>"] = '{same as} l',
  ["<CR>"] = 'go to first char on next line',
  ["<C-[>"] = 'exit back to normal mode',
  ["g<C-A>"] = 'dump memory profile',
  [":"] = 'command mode',
  ["&"] = 'repeat last :s on current line (w/o options)',
  ["g&"] = 'repeat last :s with flags',
  ["%"] = 'find forward matching bracket', -- TODO matchit?
  ["g%"] = 'find backward matching bracket', -- TODO matchit?
  ["<C-L>"] = 'clear and redraw screen',
  ["K"] = 'lookup word under cursor',
  ["gQ"] = 'switch to ex mode',
  ["gs"] = 'sleep for N seconds (default: 1)',
  ["<C-Z>"] = 'like :stop',
  ["gO"] = 'table of contents (neovim)',
  ["g<lt>"] = 'show output of previous command',
  ["g@"] = 'call operatorfunc',
  ['@:'] = 'repeat previous command',

  ['q:'] = 'edit : in command-line window',
  ['q/'] = 'edit / in command-line window',
  ['q?'] = 'edit ? in command-line window',

  -- filtering
  ["!"]  = 'filter through command to {motion}',
  ["!!"] = 'filter through command',
  ["="] = 'format lines {motion}',
  ["=="] = 'format line',
  ["gq"] = 'format (w/ formatexpr) lines to {motion}',
  ["gw"] = 'format (w/ formatoptions) lines to {motion}',

  -- folds
  ["za"] = 'toggle fold under cursor',
  ["zA"] = 'toggle fold recursively',
  ["zv"] = 'open just enough folds',
  ["zx"] = 'reset manually opened/closed folds',
  ["zX"] = 'reset manually opened/closed folds and reapply foldexpr',
  ["zC"] = 'close all folds under cursor',
  ["zD"] = 'delete all folds under cursor',
  ["zM"] = 'close all folds (fdl = 0)',
  ["zN"] = 'enable folding (set fen)',
  ["zO"] = 'open all folds under cursor',
  ["zR"] = 'open all folds (fdl = max)',
  ["zc"] = 'close fold under cursor',
  ["zd"] = 'delete fold under cursor',
  ["zE"] = 'eliminate all folds in window',
  ["zf"] = 'create a fold',
  ["zF"] = 'create a fold linewise',
  ["zi"] = 'invert foldenable',
  ["zm"] = 'fold more (fdl -= 1)',
  ["zn"] = 'disable fold (set nofen)',
  ["zo"] = 'open fold under cursor',
  ["zr"] = 'reduce folding (fdl += 1)',
  ["zk"] = 'go to previous fold',
  ["zj"] = 'go to next fold',
  ["[z"] = 'go to start of current/containing fold',
  ["]z"] = 'go to end of current/containing fold',

  -- spellcheck
  ["]s"] = 'go to next misspell',
  ["[s"] = 'go to previous misspell',
  ["]S"] = 'go to next misspell, but only bad',
  ["[S"] = 'go to previous misspell, but only bad',
  ["zg"] = 'add word under cursor as good in spellfile',
  ["zG"] = 'add word under cursor as good in internal word list',
  ["zw"] = 'add word under cursor as bad in spellfile',
  ["zW"] = 'add word under cursor as bad in internal word list',
  ["zuw"] = 'undo zw',
  ["zug"] = 'undo zg',
  ["zuW"] = 'undo zW',
  ["zuG"] = 'undo zG',
  ["z="] = 'suggest words for word under cursor',

  -- nvim terminal commands
  ['<C-\\><C-N>'] = 'go to Normal mode (no-op)',
  ['<C-\\><C-G>'] = 'go to mode specified with \'insertmode\'',

  -- window commands
  ["<C-W>+"] = 'increase window height',
  ["<C-W>-"] = 'descrease window height',
  ["<C-W><C-W>"] = 'move cursor to next window',
  ["<C-W><lt>"] = 'decrease window width',
  ["<C-W>="] = 'make windows equal height/width',
  ["<C-W>>"] = 'increase window width',
  ["<C-W>R"] = 'rotate windows upwards',
  ["<C-W>W"] = 'move cursor to previous window',
  ['<C-W>H'] = 'move window to the far left',
  ['<C-W>J'] = 'move window to the very bottom',
  ['<C-W>K'] = 'move window to the very top',
  ['<C-W>L'] = 'move window to the far right',
  ['<C-W>P'] = 'go to preview window',
  ['<C-W>S'] = '{same as} <C-W>s',
  ['<C-W>T'] = 'move window to new tab',
  ["<C-W>]"] = 'split window and jump to tag under cursor',
  ["<C-W>^"] = 'split window and edit alternate file',
  ["<C-W>_"] = 'expand window height',
  ["<C-W>b"] = 'move cursor to bottom window',
  ["<C-W>c"] = 'close window',
  ["<C-W>f"] = 'split window and edit filename under cursor (gf)',
  ["<C-W>j"] = 'move cursor to window below',
  ["<C-W>k"] = 'move cursor to window above',
  ["<C-W>n"] = 'new window',
  ["<C-W>o"] = 'close other windows',
  ["<C-W>p"] = 'move cursor to previous window',
  ["<C-W>q"] = 'close window',
  ["<C-W>r"] = 'rotate windows down',
  ["<C-W>s"] = 'split window horizontally',
  ["<C-W>t"] = 'move cursor to top window',
  ["<C-W>x"] = 'exchange window with next',
  ["<C-W>z"] = 'close preview window',
  ['<C-W>F'] = 'split and go to file w/ line (gF)',
  ['<C-W>d'] = 'split and go to definition (gd)',
  ['<C-W>h'] = 'move cursor to window left',
  ['<C-W>i'] = 'split window and jump to declaration of identifier under the cursor',
  ['<C-W>l'] = 'move cursor to window right',
  ['<C-W>v'] = 'split window vertically',
  ['<C-W>w'] = 'move cursor to next window',
  ["<C-W>|"] = 'expand window width',
  ["<C-W>}"] = 'show tag under cursor in preview window',
  ['<C-W>g]'] = 'split and :tselect tag',
  ['<C-W>g}'] = ':ptjump on tag under jursor',
  ['<C-W>gf'] = 'edit file under cursor in new tab (gf)',
  ['<C-W>gF'] = 'edit file under cursor + line in new tag (gF)',
  ['<C-W>gt'] = '{same as} gt',
  ['<C-W>gT'] = '{same as} gT',
  ['<C-W>g<Tab>'] = '{same as} g<Tab>',
  ['<C-W><C-B>'] = '{same as} <C-W>b',
  ['<C-W><C-C>'] = '{same as} <C-W>c',
  ['<C-W><C-D>'] = '{same as} <C-W>d',
  ['<C-W><C-F>'] = '{same as} <C-W>f',
  ['<C-W><C-H>'] = '{same as} <C-W>h',
  ['<C-W><C-I>'] = '{same as} <C-W>i',
  ['<C-W><C-J>'] = '{same as} <C-W>j',
  ['<C-W><C-K>'] = '{same as} <C-W>k',
  ['<C-W><C-L>'] = '{same as} <C-W>l',
  ['<C-W><C-N>'] = '{same as} <C-W>n',
  ['<C-W><C-O>'] = '{same as} <C-W>o',
  ['<C-W><C-P>'] = '{same as} <C-W>p',
  ['<C-W><C-Q>'] = '{same as} <C-W>q',
  ['<C-W><C-R>'] = '{same as} <C-W>r',
  ['<C-W><C-S>'] = '{same as} <C-W>s',
  ['<C-W><C-T>'] = '{same as} <C-W>t',
  ['<C-W><C-V>'] = '{same as} <C-W>v',
  ['<C-W><C-X>'] = '{same as} <C-W>x',
  ['<C-W><C-Z>'] = '{same as} <C-W>z',
  ['<C-W><C-]>'] = '{same as} <C-W>]',
  ['<C-W><C-^>'] = '{same as} <C-W>^',
  ['<C-W><C-_>'] = '{same as} <C-W>_',

  -- tabs
  ["gt"] = 'go to next tab',
  ["gT"] = 'go to previous tab',
  ["g<Tab>"] = 'got to last accessed tab',
  ["<C-Tab>"] = '{same as} g<Tab>',

  -- [ and ] movement
  ["[["] = 'go to start of previous section',
  ["]["] = 'go to end of next section',
  ["[]"] = 'go to end of previous section',
  ["]]"] = 'go to start of next section',
  ["[`"] = 'go to previous lowercase mark',
  ["]`"] = 'go to next lowercase mark',
  ["['"] = 'go to previous lowercase mark line',
  ["]'"] = 'go to next lowercase mark line',
  ['[c'] = 'go to previous change',
  [']c'] = 'go to next change',
  ['[f'] = '{same as} gf',
  [']f'] = '{same as} gf',

  ["[p"] = 'like p but adjust indent to current line',
  ["]p"] = 'like p but adjust to cursor under line',
  ['[P'] = '{same as} [p',
  [']P'] = '{same as} [p',

  ["[("] = 'go to previous unclosed (',
  ["])"] = 'go to next unclosed )',
  ["[{"] = 'go to previous unclosed {',
  ["]}"] = 'go to next unclosed }',

  ['[i'] = 'show first line that contains keyword under cursor',
  [']i'] = 'show next line that contains keyword under cursor',
  ['[I'] = 'list all lines containing keyword under cursor',
  [']I'] = 'list next lines containing keyword under cursor',
  ['[<C-I>'] = 'jump to previous line containing word under cursor',
  [']<C-I>'] = 'jump to next line containing word under cursor',

  ["[#"] = 'go to previous unclosed #if or #else',
  ["]#"] = 'go to next unclosed #else or #endif',
  ["[*"] = 'go to start of /* comment',
  ["]*"] = 'go to end of /* comment',
  ['[/'] = 'go to start of previous C comment',
  [']/'] = 'go to end of next C comment',

  ['[d'] = 'show first #define for keyword under cursor',
  [']d'] = 'show next #define for keyword under cursor',
  ['[D'] = 'list all #defines for word under cursor',
  [']D'] = 'list all #defines for word under cursor, searching from cursor position',
  ['[<C-D>'] = 'jump to #define for word under cursor',
  [']<C-D>'] = 'jump to #define for word under cursor, searching from cursor position',

  ["[m"] = 'go to start of previous method (java)',
  ["]m"] = 'go to start of next method (java)',
  ["[M"] = 'go to end of previous method (java)',
  ["]M"] = 'go to end of next method (java)',
}

local insert_mode_mappings = {
  -- miscellaneous
  ['<C-O>'] = 'execute a single command and return to insert',
  ['<C-Z>'] = "when 'insertmode' set: suspend Vim",
  ['<C-]>'] = 'trigger abbreviation',

  -- going back to normal mode
  ['<C-C>'] = 'quit insert mode, w/o InsertLeave event',
  ['<C-L>'] = "when 'insertmode' set: Leave Insert mode",

  -- inserting
  ['<C-@>'] = 'insert previously inserted text and stop',
  ['<C-A>'] = 'insert previously inserted text',
  ['<C-R>'] = 'insert the contents of a register',
  ['<C-E>'] = 'insert the character which is below the cursor',
  ['<C-Y>'] = 'insert the character which is above the cursor',
  ['<C-Q>'] = 'same as CTRL-V, unless used for terminal',
  ['<C-V>'] = 'insert next non-digit literally',

  -- deleting
  ['<C-U>'] = 'delete all entered characters in the current',

  -- indenting
  ['<C-T>'] = 'insert one shiftwidth of indent in current',
  ['<C-D>'] = 'delete one shiftwidth of indent in the current',

  -- duplicates of named keys
  ['<C-[>'] = 'same as <Esc>',
  ['<C-M>'] = 'same as <CR>',
  ['<C-H>'] = 'same as <BS>',
  ['<C-I>'] = 'same as <Tab>',
  ['<C-J>'] = 'same as <CR>',

  -- :lmap stuff
  ['<C-^>'] = 'toggle use of |:lmap| mappings',
  ['<C-_>'] = 'switch between languages',

  -- ctrl-g mappings
  ['<C-G>j'] = 'line down, to column where inserting started line down, to column where inserting started line down, to column where inserting started',
  ['<C-G>k'] = 'line up, to column where inserting started line up, to column where inserting started line up, to column where inserting started',
  ['<C-G>u'] = 'start new undoable edit',
  ['<C-G>U'] = "don't break undo with next cursor movement",

  -- completion
  ['<C-N>'] = 'complete, next match',
  ['<C-P>'] = 'complete, previous match',
  ['<C-X><C-D>'] = 'complete defined identifiers',
  ['<C-X><C-E>'] = 'scroll up',
  ['<C-X><C-F>'] = 'complete file names',
  ['<C-X><C-I>'] = 'complete identifiers',
  ['<C-X><C-K>'] = 'complete identifiers from dictionary',
  ['<C-X><C-L>'] = 'complete whole lines',
  ['<C-X><C-N>'] = 'next completion',
  ['<C-X><C-O>'] = 'omni completion',
  ['<C-X><C-P>'] = 'previous completion',
  ['<C-X><C-S>'] = 'spelling suggestions',
  ['<C-X><C-T>'] = 'complete identifiers from thesaurus',
  ['<C-X><C-Y>'] = 'scroll down',
  ['<C-X><C-U>'] = 'complete with \'completefunc\'',
  ['<C-X><C-V>'] = 'complete like in : command line',
  ['<C-X><C-Z>'] = 'stop completion, keeping the text as-is',
  ['<C-X><C-]>'] = 'complete tags',
  ['<C-X>s'] = 'spelling suggestions',
}

return {
  normal_mode_mappings = normal_mode_mappings,
  insert_mode_mappings = insert_mode_mappings,
  modes = {
    n = normal_mode_mappings,
    i = insert_mode_mappings,
  }
}
