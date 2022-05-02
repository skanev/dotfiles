module Mire
  module Stalker
    extend self

    def stalk(input)
      depot = Depot.instance

      beholder = Beholders::Rspec.new EventBus.new
      beholder.on_conclusion do |*args|
        args => [:event, event]
        depot.store_stalker_event event
        p event
      end

      until input.eof?
        beholder.feed_line input.readline
      end
    end
  end
end
