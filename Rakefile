require 'rake'
require 'erb'
require 'fileutils'
include FileUtils

desc "Install into the users home"
task :install => ['vim:install:vundle'] do
  Dir['*'].each do |file|
    case file
      when 'Rakefile', 'README'
        next
      when 'xprofile', 'Xdefaults', 'xmodmap'
        link_file file, home_slash(".#{file}") if `uname -s`.include? 'Linux'
      when 'TODO'
        link_file 'TODO', home_slash('.toolsmithing')
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
