module Mire
  module Beholders
    class Rspec < Beholder
      def setup
        @callbacks = []

        begin
          make_event = lambda do
            {
              quickfix: '',
              failures: [],
              rerun: '',
              beholder: :rspec,
            }
          end

          event = nil

          @bus.listen(
            start: -> { event = make_event.() },
            rerun_failed: -> (line, number) {
              /^rspec (?<file>\S+) # (?<message>.*)$/ =~ line
              event[:quickfix] << "#{file.gsub(/^\.\//, '')} #{message}\n"
              event[:rerun] << 'rspec' if number == 0
              event[:rerun] << " #{file}"
            },
            failure: -> (message, _) {
              locations = []

              message.lines.grep(/^   # ([^:]+):(\d+):(.*)$/) do
                file, line, detail = $1, $2, $3
                next if file == '-e'
                file = file.sub(/^\.\//, '')
                locations << "#{file}:#{line} #{detail}\n"
              end

              event[:failures] << locations.join
            },
            finished: -> {
              if event[:failures].empty?
                event[:title] = 'RSpec ran successfully'
                event[:status] = :success
              else
                event[:title] = "RSpec had #{event[:failures].count} failed spec(s)"
                event[:status] = :failure
              end
              notify :event, event
            },
          )
        end
      end

      def on_conclusion(&callback)
        @callbacks << callback
      end

      def notify(*args)
        @callbacks.each do |callback|
          callback.(*args)
        end
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
              consume
              emit :run_completed, $2.to_i, $1.to_i

              finish.() if $2 == '0'
            end
          in /^Failed examples:/ if running
            consume while peek =~ /^\s*$/

            i = 0

            while peek =~ /^rspec/
              emit :rerun_failed, consume.chomp, i
              i += 1
            end

            finish.()
          else
          end
        end
      end
    end
  end
end
