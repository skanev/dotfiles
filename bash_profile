source ~/.bash/aliases
source ~/.bash/paths
source ~/.bash/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

[[ -s "/home/aquarius/.rvm/scripts/rvm" ]] && source "/home/aquarius/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*
