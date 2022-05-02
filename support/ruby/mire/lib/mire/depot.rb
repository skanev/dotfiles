require 'redis-namespace'

module Mire
  class Depot
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
      event[:id] = Time.now.to_f.to_s

      @redis.lpush 'stalker:events', event.to_json
      @redis.ltrim 'stalker:events', 0, 30
    end

    def stalker_events
      @redis.lrange('stalker:events', 0, 30).map { JSON.parse _1 }
    end
  end
end
