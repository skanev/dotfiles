#!/usr/bin/zsh
# Runs in all invocations of zsh

DOTFILES=${${:-$HOME/.zsh}:A:h}

[[ -v DOTFILES_OS ]] || source ~/.zsh/distro-prober

# What /usr/libexec/path_helper does to PATH, minus the fork: prepend the
# system paths from /etc/paths and /etc/paths.d/*, keeping the list unique.
# (MANPATH is left to /etc/zprofile; man finds its pages without it.)
if [[ -r /etc/paths ]]; then
  () {
    local file
    local -a system_path
    for file in /etc/paths /etc/paths.d/*(N); do
      [[ -r $file ]] && system_path+=(${(f)"$(<$file)"})
    done
    typeset -gU path
    path=($system_path $path)
  }
fi
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
[[ -d ~/.plenv ]] && path=(~/.plenv/bin ~/.plenv/shims $path)

# mise instead of rbenv/pyenv/volta/bun (see zsh/init/S05-mise). On by
# default; DOTFILES_MISE set to empty (mise-off) brings the old managers back.
[[ -v DOTFILES_MISE ]] || export DOTFILES_MISE=1

if [[ -n $DOTFILES_MISE ]]; then
  # Shims cover non-interactive shells (editors, herdr, scripts); interactive
  # ones additionally get `mise activate` from zsh/init/S05-mise.
  path=(~/.local/share/mise/shims ${path:#$HOME/.(rbenv|pyenv|volta|bun)/*})
else
  [[ -d ~/.pyenv ]] && export PYENV_ROOT=$HOME/.pyenv
  [[ -d ~/.pyenv ]] && path=(~/.pyenv/bin ~/.pyenv/shims $path)
  [[ -d ~/.rbenv ]] && path=(~/.rbenv/bin ~/.rbenv/shims $path)
  [[ -d ~/.bun ]] && export BUN_INSTALL="$HOME/.bun"
  [[ -d ~/.bun ]] && path=($BUN_INSTALL/bin $path)
  [[ -d ~/.volta ]] && export VOLTA_HOME="$HOME/.volta"
  [[ -d ~/.volta ]] && path=(~/.volta/bin $path)
fi
[[ -d ~/.nimble/bin ]] && path=(~/.nimble/bin $path)

path=(~/bin ~/.bin $path)

[[ -f ~/.localenv ]] && source ~/.localenv

export DOTFILES_PATHS_LOADED=1

path=(/opt/homebrew/opt/postgresql@18/bin $path)

#export LDFLAGS="-L/opt/homebrew/opt/postgresql@18/lib -L/opt/homebrew/opt/jemalloc/lib"
#export CPPFLAGS="-I/opt/homebrew/opt/postgresql@18/include -L/opt/homebrew/opt/jemalloc/include"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@18/lib -L/opt/homebrew/opt/jemalloc/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@18/include -I/opt/homebrew/opt/jemalloc/include"
