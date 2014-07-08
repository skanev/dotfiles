. ~/.zsh/aliases
. ~/.zsh/env
. ~/.zsh/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

for zshrc_file in ~/.zsh/init/S[0-9][0-9]*[^~] ; do
  source $zshrc_file
done
