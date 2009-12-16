. ~/.zsh/aliases
. ~/.zsh/env
. ~/.zsh/config

for zshrc_file in ~/.zsh/init/S[0-9][0-9]*[^~] ; do
     source $zshrc_file
done

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi