module Mire
  module Beholders
    class Beholder
      def initialize(bus)
        @bus = bus

        @fiber = Fiber.new { process }
        @fiber.resume

        setup
      end

      def consume
        if @next
          result = @next
          @next = nil
          result
        else
          Fiber.yield
        end
      end

      def feed_line(line)
        @fiber.resume Mire.strip_ansi(line)
      end

      def feed_io(io)
        until io.eof?
          feed_line io.readline
        end
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
