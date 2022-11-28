require 'json'
require 'pathname'
require 'fileutils'

BINDINGS = []

class Key
  attr_reader :key

  def initialize(key, command, other = {})
    @key = key.gsub(/\bmeta\b/, VSCode.mod_key)
    @command = command
    @when = other[:when]
    @args = other[:args]
  end

  def entry(max_command_length)
    [
      '  { ',
      %("key": #{@key.to_json.+(",").ljust(max_command_length + 4)}),
      %("command": "#@command"),
      @args && %(, "args": #{@args.to_json}),
      @when && %(, "when": #{@when.to_json}),
      " },\n"
    ].compact.join
  end
end

def bind(keys, command, **kwargs)
  BINDINGS << Key.new(keys, command, kwargs)
end

module VSCode
  extend self

  DOTFILES_SEGMENT = %r{(\n *// dotfiles begin\n).*?(\n *// dotfiles end)}m

  def os
    case RUBY_PLATFORM
    in /cygwin|mswin|mingw|bccwin|wince|emx/ then :windows
    in /darwin/                              then :macos
    end
  end

  def mod_key
    case os
    in :macos   then 'cmd'
    in :windows then 'alt'
    end
  end

  def configuration_dir
    case os
    in :windows then Pathname("#{ENV['HOME']}/AppData/Roaming/Code/User")
    end
  end

  def keybindings_json_file
    Pathname(__FILE__).join("../config/keybindings.#{os}.json")
  end

  def keybindings_definition_file
    Pathname(__FILE__).join('../keybindings.rb')
  end

  def link_files
    dir = Pathname(configuration_dir)
    raise "VSCode does not seem installed (in #{dir})" unless dir.exist?
    local_keybindings = configuration_dir.join('keybindings.json')

    if local_keybindings.symlink? and local_keybindings.readlink != keybindings_json_file.realpath
      STDERR.puts "File #{local_keybindings} is a link, but is not pointing to the right direction"
      exit(1)
    elsif local_keybindings.symlink?
      puts "Already linked"
      return
    elsif local_keybindings.exist?
      puts "Removing local keybindings.json from VSCode"
      FileUtils.rm local_keybindings
    end

    FileUtils.ln_s keybindings_json_file.realpath, local_keybindings
    puts "Linked successfully"
  end

  def regenerate_keybindings
    BINDINGS.clear

    load keybindings_definition_file

    width = BINDINGS.map { _1.key.length }.max

    contents = File.read(keybindings_json_file)

    return false if contents !~ DOTFILES_SEGMENT

    contents = contents.sub(DOTFILES_SEGMENT) { "#$1\n#{BINDINGS.map { _1.entry(width) }.join}\n#$2" }
    File.write keybindings_json_file, contents
  end
end

case ARGV[0]
when 'regenerate' then VSCode.regenerate_keybindings
when 'link'       then VSCode.link_files
else raise "Unknown command: #{ARGV[0] || '-none-'}"
end
