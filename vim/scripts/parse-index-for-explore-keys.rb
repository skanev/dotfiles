# Parses vim's index.txt to extract mappings
#
# It's a bit of a throwaway, but I'll probably find it useful eventually, so
# let's keep it here. I wrote it for explain_keys so I can generate some docs
# on the default vim mappings.

INDEX_PATH = "/opt/homebrew/Cellar/neovim/0.7.0/share/nvim/runtime/doc/index.txt"
DEFAULT_MAPPINGS_PATH = 'vim/lua/explore_keys/inventory.lua'

SECTIONS = [
  'Normal mode',
  'Window commands',
  'Square bracket commands',
  "Commands starting with 'g'",
  "Commands starting with 'z'",
]

IGNORED_KEYS = %w(
  <Up> <Down> <Left> <Right>
  <Home> <End>
  <PageUp> <PageDown>
  <Del> <Insert>
  <F1> <Help> <Undo>
  <NL> <BS>
  <LeftMouse> <MiddleMouse> <RightMouse>
  <ScrollWheelUp> <ScrollWheelDown> <ScrollWheelLeft> <ScrollWheelRight>
)

DEFINED_MAPPINGS = {
  'CTRL-W_bar' => '<C-W>|'
}

def read_vim_index
  input = File.open(INDEX_PATH)
  consume = -> { input.readline }

  in_index = false
  title = nil

  last = nil

  table = {}

  until input.eof?
    line = input.readline.chomp

    considered = SECTIONS.include?(title) and in_index

    case line
    in /^=+$/
      in_index = false
      title = consume.()[/^[\d.]+ ([^\t]+)\t/, 1]
    in /^tag/
    in /^-+/
      in_index = true
    in _ if not considered
    in /^\|([^|]+)\|\t+([^\t]+)\t+(.*)/ if SECTIONS.include?(title)
      tag, _seq, text = $1, $2, $3
      next if tag =~ /^([oicv]_)/
      next if tag == "'cedit'" or tag == 'count' or tag == 'netrw-gx'
      next if tag == ":" and title == "EX commands"

      text = text.sub(/^\d  /, '').sub(/^\s+/, '')

      key = tag
      if DEFINED_MAPPINGS.include?(tag)
        key = DEFINED_MAPPINGS[tag]
      else
        key.gsub!(/_?star_?/, '*')
        key.gsub!(/_?quote_?/, '"')
        key.gsub!(/_?bar_?/, '|')
        key.gsub!(/_?CTRL-([^_]+)_?/, '<C-\1>')
        key.gsub!(/<C-<([^>]{2,}?)>>/, '<C-\1>')
        key.gsub!(/CTRL-_/, '<C-_>')
        key.gsub!('<', '<lt>') if key.length <= 2
        key.gsub!(/<$/, '<lt>')
      end

      next if IGNORED_KEYS.any? { key.sub(/^<[CS]-/, '<').include?(_1) }
      next if key =~ /^[`'].$/
      next if %w(N: N% `<lt> '<lt> z g [ ] <C-W> zN<CR> /<CR> ?<CR>).include? key

      if table.key? key
        table[key] << " " << text
      else
        table[key] = text
      end

      last = table[key]
    in /^\|!\|/
      consume.()
    in /^\t{4} {3}(.*)/ if considered
      last << " " << $1.gsub(/^\s+/, '')
    in /^\t\t([^\t]+)\t   same as "(\S+ \S+)/ if considered
    in /^\|(\S+)\| ([^\t]*)\t   (.*)$/ if considered
    in /^\|(\S+)\| ([^\t]*)  (.*)$/ if considered
    in ""
    in /^\t\t.*?   (not used|reserved)/
    in /^\S+Mouse/
    in /MiddleMouse/
    in _ if !SECTIONS.include?(title) or !in_index
    else STDERR.puts line.inspect
    end
  end

  table
end

def read_groomed_mappings
  result = {}
  File.read(DEFAULT_MAPPINGS_PATH).lines.each do |line|
    case line
    when /^\s*\[(["'])(.*?)\1\]\s+=\s+(['"])(.*)\3,(\s*--.*)?$/
      key, doc = $2, $4
      key = key.gsub('\\\\', '\\')
      result[key] = doc
    end
  end

  result
end

def dump_missing_mappings
  groomed = read_groomed_mappings

  read_vim_index.each do |key, value|
    next if groomed.key? key
    lhs = key.gsub(/(['\\])/) { "\\#$1" }
    doc = value.gsub(/(['\\])/) { "\\#$1" }
    puts %{  ['#{lhs}'] = '#{doc}',}
  end
end

dump_missing_mappings
