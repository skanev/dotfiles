require 'stringio'
require 'json'

file = ARGV[0]

raise "No file given" unless file
raise "File does not exist: #{file}" unless File.exist? file

code = File.read file

code = code.gsub(/#STOPHERE.*/m, '')

transformed = []
output = []

code.lines.each_with_index do |line, row|
  line = line.chomp
  placeholder = "\#{#{row}}"

  case line
  when /^\s*#\.\s*$/
    transformed << ".tap { |_value| capture(#{row}) { _value } }"
    output << "#{line} #{placeholder}"
  when /^\s*#\s*$/
    transformed[-1] = "capture(#{row}) {\n#{transformed[-1]}\n}"
    output << "#{line} #{placeholder}"
  when /^(.*\S\s+)#\.\s*$/
    transformed << "#$1.tap { |_value| capture(#{row}) { _value } }"
    output << "#{line} #{placeholder}"
  when /^(.*\S\s+)#\s*$/
    transformed << "capture(#{row}) {\n#$1\n}"
    output << "#{line} #{placeholder}"
  when /^ {0,2}(puts|p) /
    transformed << "capture_output(#{row}) {\n#{line} }"
    output << "#{line} #{placeholder}"
  else
    transformed << line
    output << line
  end
end

$captures = {}

def capture_output(number)
  previous = $stdout
  $stdout = StringIO.new
  yield
  output = "#{$stdout.string.chomp.gsub("\n", " ⏎ ")}"
  if $captures[number]
    $captures[number] += " ⏎ #{output}"
  else
    $captures[number] = "# #{output}"
  end
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

if ARGV[1] == '--print'
  puts output.join("\n").gsub(/#\{(\d+)\}$/) { "#{$captures[$1.to_i]}" }
else
  puts JSON.dump $captures
end
