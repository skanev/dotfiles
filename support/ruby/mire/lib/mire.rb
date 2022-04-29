require_relative 'mire/tmux'

module Mire
  extend self

  class EventBus
    def initialize
      @listeners = []
    end

    def listen(listener)
      @listeners << listener
    end

    def emit(event, *args)
      @listeners.each do |listener|
        case listener
        when Proc
          listener.(event, *args)
        when Hash
          listener[event]&.(*args)
        else
          raise "Unknown listener: #{listener.inspect}"
        end
      end
    end
  end

  def track_hivemind(io)
    bus = EventBus.new
    yield bus

    location = nil
    next_line_is_error = false
    compiling = false
    errors = 0

    start = lambda do
      errors = 0
      compiling = true
      bus.emit :start
    end

    error = lambda do |message|
      bus.emit :error, message
      errors += 1
    end

    finish = lambda do |success|
      bus.emit :finish, errors

      compiling = false
      errors = 0
    end

    until io.eof?
      line = io.readline
      bus.emit :line, line

      line = line.chomp.gsub(/\033\[\d{1,2}(;\d{1,2}){0,3}[mGK]/, '')

      if line.start_with? 'webpack |'
        line = line.sub(/^webpack \| /, '')
      else
        next
      end

      if line =~ /^(?:ERROR in) (.*)$/
        start.() unless compiling
        location = $1
        next_line_is_error = true
      elsif next_line_is_error
        error.("#{location} #{line}")
        location = nil
        next_line_is_error = false
      elsif line =~ /^Found \d+ errors? in \d+ ms\.$/
        finish.(false)
      elsif line == 'Type-checking in progress...'
        start.()
      elsif line == 'No errors found.'
        start.() unless compiling
        finish.(true)
      else
        next
      end
    end
  ensure
    bus.emit :exit
  end
end
