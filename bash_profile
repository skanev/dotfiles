source ~/.bash/aliases
source ~/.bash/paths
source ~/.bash/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

complete -C /opt/homebrew/bin/terraform terraform

export PATH="$HOME/.poetry/bin:$PATH"
