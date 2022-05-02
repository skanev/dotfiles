require 'spec_helper'

module Mire
  module Beholders
    describe Rubocop do
      let(:events) { [] }
      let(:stalker_events) { [] }

      def strip_heredoc(text)
        text.gsub(/^\s*\|/, '')
      end

      def behold(text)
        bus = EventBus.new
        bus.listen -> (*args) { events << args }

        beholder = Rubocop.new(bus)
        beholder.on_conclusion do |*args|
          args => [:event, event]
          stalker_events << event
        end
        beholder.feed_io StringIO.new(text)
      end

      it 'supports a standard run' do
        behold <<~END
          → rubocop
          Inspecting 4 files
          ....

          Offenses:

          dir/first.rb:1:2: W: Lint/UselessAssignment: Useless assignment to variable - foo.
              foo = 1
              ^^^^
          dir/second.rb:2:3: C: [Correctable] Layout/ExtraSpacing: Unnecessary spacing detected.
              bar  = 1


          1 file inspected, 2 offenses detected
        END

        expected = [
          [:start],
          [:offense, 'dir/first.rb:1:2 Lint/UselessAssignment: Useless assignment to variable - foo.', strip_heredoc(<<~END)],
            |    foo = 1
            |    ^^^^
            END
          [:offense, 'dir/second.rb:2:3 Layout/ExtraSpacing: Unnecessary spacing detected.', strip_heredoc(<<~END)],
            |  bar  = 1
            |
            END
          [:completed, 2],
          [:finished],
        ]

        events.should eq expected
      end

      pending 'supports a successful run'
    end
  end
end
