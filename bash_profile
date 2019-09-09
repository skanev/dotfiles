source ~/.bash/aliases
source ~/.bash/paths
source ~/.bash/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

export PATH="$HOME/.rbenv/bin:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# added by Anaconda3 5.0.0 installer
export PATH="/Users/aquarius/anaconda3/bin:$PATH"
