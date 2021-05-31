require 'stringio'
require 'json'

file = ARGV[0]

raise "No file given" unless file
raise "File does not exist: #{file}" unless File.exist? file

code = File.read file

code = code.gsub(/#STOPHERE.*/m, '')

transformed = []

code.lines.each_with_index do |line, row|
  line = line.chomp

  case line
  when /^\s*#\.\s*$/
    transformed << ".tap { |_value| capture(#{row}) { _value } }"
  when /^\s*#\s*$/
    transformed[-1] = "capture(#{row}) {\n#{transformed[-1]}\n}"
  when /^(.*\S\s+)#\.\s*$/
    transformed << "#$1.tap { |_value| capture(#{row}) { _value } }"
  when /^(.*\S\s+)#\s*$/
    transformed << "capture(#{row}) {\n#$1\n}"
  when /^ {0,2}(puts|p) /
    transformed << "capture_output(#{row}) {\n#{line} }"
  else
    transformed << line
  end
end

$captures = {}

def capture_output(number)
  previous = $stdout
  $stdout = StringIO.new
  yield
  $captures[number] = "# #{$stdout.string.chomp.gsub("\n", " ⏎ ")}"
ensure
  $stdout = previous
end

def capture(number)
  result = yield
  $captures[number] = result.inspect
rescue => e
  $captures[number] = "thrown #{e.inspect}"
end

$stdout = StringIO.new
eval transformed.join("\n")
$stdout = STDOUT

puts JSON.dump $captures
