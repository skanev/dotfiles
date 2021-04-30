#!/usr/bin/env zsh
# Runs in login shells

[ -x /usr/libexec/path_helper ] && eval `/usr/libexec/path_helper -s`

path=(~/bin $path)

[[ -d /usr/local/opt/coreutils/libexec/gnubin ]] && path=(/usr/local/opt/coreutils/libexec/gnubin $path)

[[ -d /usr/local/opt/gnu-sed/libexec/gnubin ]] && path=(/usr/local/opt/gnu-sed/libexec/gnubin $path)

[[ -d ~/.pyenv ]] && export PYENV_ROOT=$HOME/.pyenv
[[ -d ~/.pyenv ]] && path=(~/.pyenv/bin ~/.pyenv/shims $path)
[[ -d ~/.plenv ]] && path=(~/.plenv/bin ~/.plenv/shims $path)
[[ -d ~/.rbenv ]] && path=(~/.rbenv/bin ~/.rbenv/shims $path)

[[ -f ~/.localprofile ]] && . ~/.localprofile
