module Mire
  module Stalker
    extend self

    def stalk(input)
      depot = Depot.instance

      beholders = [
        Beholders::Rspec.new(EventBus.new),
        Beholders::Rubocop.new(EventBus.new),
      ]

      beholders.each do |beholder|
        beholder.on_conclusion do |type, data|
          case type
          in :event then depot.store_stalker_event data
          else
          end
        end
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
