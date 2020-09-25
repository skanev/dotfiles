#!/usr/bin/env zsh
# Runs in login shells

if [ -x /usr/libexec/path_helper ]; then
    eval `/usr/libexec/path_helper -s`
fi

path=(~/bin $path)

if [[ -d ~/.rbenv ]]; then
    path=(~/.rbenv/bin ~/.rbenv/shims $path)
fi

if [[ -d ~/.pyenv ]]; then
    export PYENV_ROOT=$HOME/.pyenv
    path=(~/.rbenv/bin ~/.rbenv/shims ~/.pyenv/bin $path)
fi
