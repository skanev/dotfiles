#!/usr/bin/env zsh
# Runs in interactive session

DOTFILES=${$(readlink ~/.zsh):h}

. ~/.zsh/config

[[ -f ~/.localrc ]] && source ~/.localrc

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
  after=$(date +%s.%N)
  (( elapsed = $after - $TIME_BEFORE_TE ))
  unset TIME_BEFORE_TE
  echo "Time to load: $elapsed"
fi

# Global aliases can mess up everything else, so they must be last
. ~/.zsh/aliases
