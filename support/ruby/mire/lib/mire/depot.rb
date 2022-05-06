require 'redis-namespace'

module Mire
  class Depot
    EVENTS_KEPT = 100

    def self.instance
      @instance ||= new
    end

    def initialize
      redis = Redis.new
      redis.select(7)

      @redis = Redis::Namespace.new('mire', redis:)
    end

    def store_stalker_event(event)
      event = event.dup
      now = Time.now
      event[:id] = now.to_f.to_s
      event[:timestamp] = now.to_s

      @redis.lpush 'stalker:events', event.to_json
      @redis.ltrim 'stalker:events', 0, EVENTS_KEPT
    end

    def stalker_events
      @redis.lrange('stalker:events', 0, EVENTS_KEPT).map { JSON.parse _1 }
    end

    def publish(message)
      @redis.publish 'mire', message
    end

    def subscribe(&block)
      @redis.subscribe 'mire' do |on|
        on.message do |_, message|
          block.(message)
        end
      end
    end
  end
end
