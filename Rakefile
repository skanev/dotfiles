require 'rake'
require 'erb'
require 'fileutils'
include FileUtils

desc "Install into the users home"
task :install do
  Dir['*'].each do |file|
    case file
      when 'Rakefile', 'README'
        next
      when 'TODO'
        link 'TODO', home_slash('.toolsmithing')
      when 'bin'
        unless File.directory? home_slash('bin')
          mkdir home_slash('bin'), :verbose => false
        end
        
        Dir['bin/*'].each do |bin_file|
          link bin_file, home_slash(bin_file)
        end
      else
        link file, home_slash(".#{file}")
    end
  end
end

def home() ENV['HOME'] end
def home_slash(name) File.join(home, name) end

def link(source, target)
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
    ln_s File.join(Dir.pwd, source), target, :verbose => false
  elsif action == :skip
    puts "skipping #{target}"
  end
end
