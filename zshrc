#!/usr/bin/env zsh
# Runs in interactive session

. ~/.zsh/config

[[ -f ~/.localrc ]] && source ~/.localrc

if [[ ! $fpath = *$USER/.zsh/functions* ]];then
  fpath=(~$USER/.zsh/functions ~$USER/.zsh/completions $fpath)
  autoload ${fpath[1]}/*(:t) ${fpath[2]}/*(:t)
fi

for zshrc_file in ~/.zsh/init/S[0-9][0-9]*[^~] ; do
  source $zshrc_file
done

[[ -e "~/.iterm2_shell_integration.zsh" ]] && . "~/.iterm2_shell_integration.zsh"

if [[ -n $DOTFILES_POSITION_KITTY ]]; then
  unset DOTFILES_POSITION_KITTY
  ~/.scripts/position-me kitty
fi

if [[ -n $TIME_BEFORE_TE ]]; then
  local after elapsed

  if which gdate > /dev/null 2>&1; then
    after=$(gdate +%s.%N)
  else
    after=$(date +%s.%N)
  fi

  (( elapsed = $after - $TIME_BEFORE_TE ))
  unset TIME_BEFORE_TE
  echo "Time to load: $elapsed"
fi

# Global aliases can mess up everything else, so they must be last
. ~/.zsh/aliases

if [[ $DOTFILES_OS == "mac" && -d ~/.rbenv && $(whence ruby) == "/usr/bin/ruby" ]]; then
  echo "\e[33mRuby is resolving to $(which ruby) instead of ~/.rbenv/shims/ruby; maybe you should run zsh setup/packs/mac_setup install\e[0m"
fi

eval "$(scmpuff init -s)"

export PATH="$VOLTA_HOME/bin:$PATH"
export PATH="~/bin:$PATH"
export PATH="$HOME/.rd/bin:$PATH"

export VOLTA_HOME="$HOME/.volta"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
