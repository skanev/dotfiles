#!/usr/bin/zsh
# Runs in all invocations of zsh

DOTFILES=${$(readlink ~/.zsh):h}

[[ -v DOTFILES_OS ]] || source ~/.zsh/distro-prober

[[ -x /usr/libexec/path_helper ]] && eval `/usr/libexec/path_helper -s`
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin /opt/homebrew/sbin $path)

[[ -d /usr/local/opt/coreutils/libexec/gnubin ]] && path=(/usr/local/opt/coreutils/libexec/gnubin $path)
[[ -d /usr/local/opt/gnu-sed/libexec/gnubin   ]] && path=(/usr/local/opt/gnu-sed/libexec/gnubin $path)

if [[ $DOTFILES_OS != mac && -d /home/linuxbrew ]]; then
  export HOMEBREW_PREFIX="/home/linuxbrew/.linuxbrew"
  export HOMEBREW_CELLAR="/home/linuxbrew/.linuxbrew/Cellar"
  export HOMEBREW_REPOSITORY="/home/linuxbrew/.linuxbrew/Homebrew"

  path=(/home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin $path)
  infopath=(/home/linuxbrew/.linuxbrew/share/info $infopath)
  manpath=(/home/linuxbrew/.linuxbrew/share/man $manpath)
fi

[[ -d ~/.cargo ]] && path=(~/.cargo/bin $path)
[[ -d ~/.pyenv ]] && export PYENV_ROOT=$HOME/.pyenv
[[ -d ~/.pyenv ]] && path=(~/.pyenv/bin ~/.pyenv/shims $path)
[[ -d ~/.plenv ]] && path=(~/.plenv/bin ~/.plenv/shims $path)
[[ -d ~/.rbenv ]] && path=(~/.rbenv/bin ~/.rbenv/shims $path)
[[ -d ~/.volta ]] && export VOLTA_HOME="$HOME/.volta"
[[ -d ~/.volta ]] && path=(~/.volta/bin $path)
[[ -d ~/.bun ]] && export BUN_INSTALL="$HOME/.bun"
[[ -d ~/.bun ]] && path=($BUN_INSTALL/bin $path)
[[ -d ~/.nimble/bin ]] && path=(~/.nimble/bin $path)

path=(~/bin ~/.bin $path)

[[ -f ~/.localenv ]] && source ~/.localenv

export DOTFILES_PATHS_LOADED=1
