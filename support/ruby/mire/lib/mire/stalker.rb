module Mire
  module Stalker
    extend self

    def stalk(input)
      depot = Depot.instance

      bus = EventBus.new

      beholders = [
        Beholders::Rspec.new(bus),
        Beholders::Rubocop.new(bus),
      ]

      bus.listen stalker: -> (data) do
        depot.store_stalker_event data
      end

      until input.eof?
        line = input.readline
        beholders.each do |beholder|
          beholder.feed_line line
        end
      end
    end
  end
end
