require 'json'
require 'pathname'

BINDINGS = []

class Key
  attr_reader :key

  def initialize(key, command, other = {})
    @key = key.gsub(/\bmeta\b/, 'cmd')
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

  def keybindings_json_file
    Pathname(__FILE__).join('../config/keybindings.mac.json').to_s
  end

  def keybindings_definition_file
    Pathname(__FILE__).join('../keybindings.rb').to_s
  end

  def regenerate_keybindings
    BINDINGS.clear

    load keybindings_definition_file

    width = BINDINGS.map { _1.key.length }.max

    contents = File.read(keybindings_json_file)

    return false if contents !~ DOTFILES_SEGMENT

    contents = contents.sub(DOTFILES_SEGMENT) { "#$1\n#{BINDINGS.map { _1.entry(width) }.join}\n#$2" }
    File.write keybindings_json_file, contents

    true
  end
end
