source ~/.bash/aliases
source ~/.bash/paths
source ~/.bash/config

if [ -f ~/.localrc ]; then
  . ~/.localrc
fi

# mise by default, like zshenv; DOTFILES_MISE set to empty brings rbenv back
[ -z "${DOTFILES_MISE+x}" ] && export DOTFILES_MISE=1

if [ -n "$DOTFILES_MISE" ]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
else
  export PATH="$HOME/.rbenv/bin:$PATH"
  if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi
fi
