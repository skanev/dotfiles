# Runs in interactive session
. ~/.zsh/env
. ~/.zsh/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

for zshrc_file in ~/.zsh/init/S[0-9][0-9]*[^~] ; do
  source $zshrc_file
done

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

. ~/.zsh/aliases # Global aliases can mess up everything else
