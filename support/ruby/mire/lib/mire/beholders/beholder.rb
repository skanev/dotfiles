module Mire
  module Beholders
    class Beholder
      class << self
        def build
          new EventBus.new
        end
      end

      def initialize(bus)
        @bus = bus

        @fiber = Fiber.new { process }
        @fiber.resume

        setup
      end

      def consume
        read_next
        result, @next = @next, nil
        result
      end

      def feed_line(line)
        @fiber.resume Mire.strip_ansi(line)
      end

      def feed_io(io)
        feed_line io.readline until io.eof?
      end

      def feed_pipe(pipe, chunk_size = 1024)
        buffer = ''

        until pipe.eof?
          part = pipe.readpartial(chunk_size)
          yield part
          buffer << part

          next unless part.include? "\n"

          *lines, buffer = buffer.split("\n")

          lines.each do |line|
            line << "\n"
            feed_line line
          end
        end

        return if buffer == ''

        buffer += "\n"
        feed_line buffer
      end

      private

      def setup
      end

      def peek
        read_next
        @next
      end

      def read_next
        return if @next

        @next = Fiber.yield
      end

      def emit(event, *args)
        @bus.emit event, *args
      end
    end
  end
end
