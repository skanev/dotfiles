" Since the names in my dotfiles are a bit weird, Vim needs a little help to
" detect which is which. I've consolidated them in one place instead of having
" separate ftdetect files.

autocmd BufNewFile,BufReadPost gitconfig setfiletype gitconfig
autocmd BufNewFile,BufReadPost */mutt/*  setfiletype muttrc
