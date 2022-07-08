setup/install

brew install scmpuff
brew tap homebrew/cask-fonts
brew install --cask font-fira-code-nerd-font

touch ~/.jumplist
echo "export DOTFILES_CONTEXTS_EXTRA=~/My\ Drive/dotfiles/contexts" > ~/.localrc
ln -s ~/My\ Drive/dotfiles/contexts ~/.contexts

touch ~/.gitconfig.local
git config -f ~/.gitconfig.local user.name "Vladimir Konushliev"
git config -f ~/.gitconfig.local user.email "v.konushliev@gmail.com"

