module Mire
  module Beholders
    class Rubocop < Beholder
      def setup
        @callbacks = []

        begin
          make_event = lambda do
            {
              quickfix: '',
              rerun: '',
              beholder: :rubocop,
            }
          end

          event = nil

          @bus.listen(
            start: -> { event = make_event.() },
            offense: -> (message, _) {
              file = message.split(':', 2).first

              event[:quickfix] << "#{message}\n"
              event[:rerun] << "#{file} "
            },
            finished: -> {
              failures = event[:quickfix].count("\n")
              if failures.zero?
                event[:title] = 'Rubocop ran successfully'
                event[:status] = :success
              else
                event[:title] = "Rubocop found #{failures} offense(s)"
                event[:status] = :failure
              end

              event[:rerun] = "rubocop #{event[:rerun].strip.split.uniq.join(' ')}" if event[:rerun] != ''
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
        reporting_offenses = false

        start = lambda do
          emit :start
          reporting_offenses = true
        end

        finish = lambda do
          emit :finished
          reporting_offenses = false
        end

        loop do
          line = consume

          case line
          in /^(Inspecting \d+ file?|Offenses:)/ unless reporting_offenses
            start.()
          in /^([^: ]+):(\d+):(\d+): (?:[WC]):(?: \[Correctable\])? (.*)$/ if reporting_offenses
            file, line, column, message = $1, $2, $3, $4
            summary = "#{file}:#{line}:#{column} #{message}"
            detail = ''
            2.times do
              break if peek =~ /^([^: ]+:\d+:\d+: [WC]|\d+ files? inspected)/
              detail << consume
            end
            emit :offense, summary, detail
          in /^\d+ files? inspected, (\d+|no) offenses? detected(?:, \d+ offenses? auto-correctable)?/ if reporting_offenses
            emit :completed, $1.to_i
            finish.()
          else
          end
        end
      end
    end
  end
end
