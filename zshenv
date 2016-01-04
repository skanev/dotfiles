#!/usr/bin/zsh
if [[ -d ~/.rbenv ]]; then
    path=(~/.rbenv/bin ~/.rbenv/shims $path)
fi
