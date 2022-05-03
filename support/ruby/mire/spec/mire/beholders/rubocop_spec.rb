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
                 ^

          1 file inspected, 2 offenses detected
        END

        expected = [
          [:start],
          [:offense,
           'dir/first.rb:1:2 Lint/UselessAssignment: Useless assignment to variable - foo.',
           strip_heredoc(<<~END),
             |    foo = 1
             |    ^^^^
           END
          ],
          [:offense,
           'dir/second.rb:2:3 Layout/ExtraSpacing: Unnecessary spacing detected.',
           strip_heredoc(<<~END)],
             |    bar  = 1
             |       ^
           END
          [:completed, 2],
          [:finished],
        ]

        events.should eq expected

        stalker_events.should match [
          a_hash_including(
            title: 'Rubocop found 2 offense(s)',
            status: :failure,
            quickfix: <<~END,
              dir/first.rb:1:2 Lint/UselessAssignment: Useless assignment to variable - foo.
              dir/second.rb:2:3 Layout/ExtraSpacing: Unnecessary spacing detected.
            END
            rerun: 'rubocop dir/first.rb dir/second.rb',
          ),
        ]
      end

      it 'handles offenses without a detail' do
        behold <<~END
          Inspecting 4 files
          ....

          dir/first.rb:1:1: C: Lint/First: First offense
          dir/second.rb:2:2: W: Lint/Second: Second offense
            if event = something
                     ^
          dir/third.rb:3:3: C: Lint/Third: Third offense

          4 files inspected, 3 offenses detected
        END

        expected = [
          [:start],
          [:offense, 'dir/first.rb:1:1 Lint/First: First offense', ''],
          [:offense, 'dir/second.rb:2:2 Lint/Second: Second offense', strip_heredoc(<<~END)],
            |  if event = something
            |           ^
          END
          [:offense, 'dir/third.rb:3:3 Lint/Third: Third offense', "\n"],
          [:completed, 3],
          [:finished],
        ]

        events.should eq expected
      end

      it 'handles a successful run' do
        behold <<~END
          → rubocop
          Inspecting 14 files
          ..............

          14 files inspected, no offenses detected
        END

        expected = [
          [:start],
          [:completed, 0],
          [:finished],
        ]

        events.should eq expected

        stalker_events.should eq [{
          title: 'Rubocop ran successfully',
          beholder: :rubocop,
          status: :success,
          quickfix: '',
          rerun: '',
        }]
      end
    end
  end
end
