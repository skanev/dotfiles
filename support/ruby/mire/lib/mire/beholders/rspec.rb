module Mire
  module Beholders
    class Rspec < Beholder
      def setup
        make_state = lambda do
          {
            failures: [],
          }
        end

        state = nil

        @internal_bus.listen(
          start: -> do
            state = make_state.()
          end,
          failure: -> (message, num) do
            failure = state[:failures][num] = {
              stacktrace: [],
              file: nil,
              line: nil,
              message: nil,
              title: nil,
            }

            failure[:message] = message[/\A[^\n]+\n(.*?)^   (?:Shared Example Group|#)/m, 1]

            message.lines.each do |line|
              file, line_number, detail = nil, nil, nil

              case line
              when /^   # ([^:]+):(\d+):(.*)$/
                file, line_number, detail = $1, $2, $3
                next if file == '-e'
                file = file.sub(/^\.\//, '')
              when /^   Shared Example Group: "(.*)" called from (.*):(\d+)$/
                name, file, line_number = $1, $2, $3
                detail = "in shared example: #{name}"
              else
                next
              end

              file = file.sub(/^\.\//, '')
              failure[:stacktrace].push [file, line_number.to_i, detail]
            end
          end,
          rerun_failed: -> (line, number) do
            /^rspec (?<file_and_line>\S+) # (?<title>.*)$/ =~ line or raise
            /^(?:\.\/)?(?<file>[^:]+):(?<line_number>\d+)$/ =~ file_and_line or raise

            state[:failures][number][:file] = file
            state[:failures][number][:line] = line_number.to_i
            state[:failures][number][:title] = title
          end,
          finished: -> do
            failures = state[:failures]
            notify :stalker, {
              beholder: :rspec,
              title: failures.empty? ? 'RSpec ran successfully' : "RSpec had #{failures.count} failed spec(s)",
              status: failures.empty? ? :success : :failure,
              quickfix: failures.map { _1 => {file:, line:, title:} ; "#{file}:#{line} #{title}\n" }.join,
              failures: failures.map { |failure| failure[:stacktrace].map { "#{_1[0]}:#{_1[1]} #{_1[2]}\n" }.join },
              rerun: failures.empty? ? '' : "rspec #{failures.map { "./#{_1[:file]}:#{_1[:line]}" }.join(' ')}",
            }

            notify :fire, {
              status: failures.empty? ? :success : :failure,
              failures: failures.map do |failure|
                {
                  file: failure[:file],
                  line: failure[:line],
                  stacktrace: failure[:stacktrace],
                  title: failure[:title],
                  message: failure[:message],
                  message_hint: self.class.failure_message_hint(failure[:message]),
                }
              end,
            }

            state = nil
          end,
        )
      end

      def process
        running = false

        start = lambda do
          emit :start
          running = true
        end

        finish = lambda do
          emit :finished
          running = false
        end

        loop do
          line = consume

          case line
          in /^Pending:/
            consume while peek =~ /^( |$)/
          in /^  (\d+)\) (.*)$/
            start.() unless running

            number = $1.to_i
            message = [line.sub(/^  /, '')]

            message << consume.sub(/^  /, '') while peek =~ /^(    |$)/

            message = message.join

            emit :failure, message.chomp, number.to_i - 1
          in /^Finished in \S+ seconds?/
            start.() unless running

            if peek =~ /^(\d+) examples?, (\d+) failures?/
              failures = $2.to_i
              consume
              emit :run_completed, failures, $1.to_i

              if failures.nonzero?
                consume until peek =~ /^rspec /
                failures.times do |i|
                  emit :rerun_failed, consume.chomp, i
                end
              end

              finish.()
            end
          else
          end
        end
      end

      class << self
        def failure_message_hint(message)
          hint =
            case message
            when /^ +expected: (.*)\n +got: (.*)\n *\n +\(compared using (.*?)\)/
              "#$1 #$3 #$2"
            when /\A(Failure\/Error): (?<code>([^\n]*)(\n +[^\n]*)*)(?<details>.*)/m
              $~['details']
            else
              message
            end

          hint.gsub(/\s+/, ' ').sub(/^\A\s+/, '').sub(/\s+\z/, '')
        end
      end
    end
  end
end
