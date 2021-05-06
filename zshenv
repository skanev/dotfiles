#!/usr/bin/zsh
# Runs in all invocations of zsh

[[ -v DOTFILES_OS ]] || source ~/.zsh/distro-prober

[[ -x /usr/libexec/path_helper ]] && eval `/usr/libexec/path_helper -s`

[[ -d /usr/local/opt/coreutils/libexec/gnubin ]] && path=(/usr/local/opt/coreutils/libexec/gnubin $path)
[[ -d /usr/local/opt/gnu-sed/libexec/gnubin   ]] && path=(/usr/local/opt/gnu-sed/libexec/gnubin $path)

[[ -d ~/.cargo ]] && path=(~/.cargo/bin $path)
[[ -d ~/.pyenv ]] && export PYENV_ROOT=$HOME/.pyenv
[[ -d ~/.pyenv ]] && path=(~/.pyenv/bin ~/.pyenv/shims $path)
[[ -d ~/.plenv ]] && path=(~/.plenv/bin ~/.plenv/shims $path)
[[ -d ~/.rbenv ]] && path=(~/.rbenv/bin ~/.rbenv/shims $path)

path=(~/bin $path)

[[ -f ~/.localenv ]] && source ~/.localenv

if [[ -d /home/linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew";
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar";
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew";
  export PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin${PATH+:$PATH}";
  export MANPATH="/home/linuxbrew/.linuxbrew/share/man${MANPATH+:$MANPATH}:";
  export INFOPATH="/home/linuxbrew/.linuxbrew/share/info:${INFOPATH:-}";
fi
