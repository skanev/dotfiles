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
  zmodload zsh/datetime
  printf "Time to load: %.3fs\n" $(( EPOCHREALTIME - TIME_BEFORE_TE ))
  unset TIME_BEFORE_TE
fi

# Global aliases can mess up everything else, so they must be last
. ~/.zsh/aliases

if [[ $DOTFILES_OS == "mac" && -d ~/.rbenv && $(whence ruby) == "/usr/bin/ruby" ]]; then
  echo "\e[33mRuby is resolving to $(which ruby) instead of ~/.rbenv/shims/ruby; maybe you should run zsh setup/packs/mac_setup install\e[0m"
fi

[[ -d ~/.local/bin ]] && path=(~/.local/bin $path)

# bun completions
#[ -s "/Users/aquarius/.bun/_bun" ] && source "/Users/aquarius/.bun/_bun"

# bun
#export BUN_INSTALL="$HOME/.bun"
#export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/Users/aquarius/.opencode/bin:$PATH

# --- Gas Town Integration (managed by gt) ---
#[[ -f "/Users/aquarius/.config/gastown/shell-hook.sh" ]] && source "/Users/aquarius/.config/gastown/shell-hook.sh"
# --- End Gas Town ---
