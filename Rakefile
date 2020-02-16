require 'rake'
require 'erb'
require 'fileutils'
include FileUtils

desc "Install into the users home"
task :install do
  Dir['*'].each do |file|
    case file
      when 'Rakefile', 'README', 'README.markdown'
        next
      when 'xprofile', 'Xdefaults', 'xmodmap'
        link_file file, home_slash(".#{file}") if `uname -s`.include? 'Linux'
      when 'bin'
        unless File.directory? home_slash('bin')
          mkdir home_slash('bin'), :verbose => false
        end

        Dir['bin/*'].each do |bin_file|
          link_file bin_file, home_slash(bin_file)
        end
      else
        link_file file, home_slash(".#{file}")
    end
  end
end

desc "Install and configure VSCode (TODO: merge into common install)"
task :vscode do
  system 'brew cask install visual-studio-code'

  vscode_user_dir = home_slash 'Library/Application Support/Code/User'

  mkdir_p vscode_user_dir, :verbose => false unless File.directory? vscode_user_dir
  link_file 'vscode/settings.json', vscode_user_dir + 'settings.json'

  %w(
    agilepixel.chalkboard
    apollographql.vscode-apollo
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    firefox-devtools.vscode-firefox-debug
    formulahendry.code-runner
    kenziebottoms.chalkboard
    larscom.monokai-dark-vibrant
    ms-vscode.vscode-typescript-tslint-plugin
    stylelint.vscode-stylelint
    sianglim.slim
    stkb.rewrap
    vscodevim.vim
    styleling
  ).each do |extension|
    system "code --install-extension #{extension}"
  end

  # Enable key-repeating for the VIM plugin
  system "defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false"

  p 'done'
end

desc "Installs the stuff in homebrew I need"
task :homebrew do
  formulas = %w(
    ack
    figlet
    fzf
    htop
    macvim
    midnight-commander
    reattach-to-user-namespace
    scmpuff
    the_silver_searcher
    tmux mercurial
    tree
    vim
    watch
    wget
    zsh
    zsh-lovers
  )
  exec "brew", "install", *formulas
end

desc "Installs homebrew casks"
task :casks do
  casks = %w(fluor dash)
  exec "brew", "cask", "install", *casks
end

def home() ENV['HOME'] end
def home_slash(name) File.join(home, name) end

def link_file(source, target)
  action = if File.symlink?(target)
    if $replace_all
      :overwrite
    else
      print "Overwrite #{target}? [yNqa] "
      case $stdin.gets.chomp
        when 'a' then ($replace_all = true) and :overwrite
        when 'y' then :overwrite
        when 'q' then exit
        else :skip
      end
    end
  else
    :link
  end

  if [:link, :overwrite].include? action
    if action == :overwrite
      puts "Overwriting #{target}"
      rm target, :verbose => false
    end
    ln_s File.join(Dir.pwd, source), target, :verbose => true
  elsif action == :skip
    puts "skipping #{target}"
  end
end

def each_bundle
  bundles = `git submodule --quiet foreach 'echo $path'`.map { |line| line.chomp }
  bundles.each do |bundle_path|
    cd bundle_path, :verbose => false do
      yield bundle_path
    end
  end
end
