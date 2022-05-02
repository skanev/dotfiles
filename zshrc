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

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
#export SDKMAN_DIR="$HOME/.sdkman"
#[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export PATH="$HOME/.poetry/bin:$PATH"
