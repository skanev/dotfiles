module SpecHelpers
  module BeholderHelpers
    module ClassMethods
    end

    def self.included(base)
      base.extend ClassMethods

      base.let(:internal_events) { [] }
      base.let(:external_events) { [] }
    end

    def behold(text)
      beholder = described_class.build do |bus|
        bus.listen -> (*args) { external_events << args }
      end

      beholder.internal_bus.listen -> (*args) { internal_events << args }
      beholder.feed_io StringIO.new(text)
    end

    def stalker_events
      external_events.filter { _1[0] == :stalker }.map { _1[1] }
    end

    def fire_events
      external_events.filter { _1[0] == :fire }.map { _1[1] }
    end

    def events
      internal_events
    end
  end
end
