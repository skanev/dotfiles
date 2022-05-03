require 'spec_helper'

module Mire
  module Beholders
    describe Rspec do
      let(:events) { [] }
      let(:stalker_events) { [] }

      def behold(text)
        bus = EventBus.new
        bus.listen -> (*args) { events << args }

        beholder = Rspec.new(bus)
        beholder.on_conclusion do |*args|
          args => [:event, event]
          stalker_events << event
        end
        beholder.feed_io StringIO.new(text)
      end

      it 'supports a complicated failure' do
        behold <<~END
          → rspec --format documentation spec/spec_someting_spec.rb
          Running via Spring preloader in process 12345
          .F.F

          Main spec
            first failure (FAILED - 1)
            second failure (FAILED - 2)
            first success
            second success

          Failures:

            1) Main spec first failure
               Failure/Error
                 First error message
                 is on two lines
               # ./first/one.rb:1:in `first'
               # ./first/two.rb:2:in `block in first'
               # -e:1:in `<main>'

            2) Main spec second failure
               Failure/Error: 1.should eq 2

                 expected: 2
                      got: 1

                 (compared using ==)
               # ./second/one.rb:1:in `second'
               # -e:1:in `<main>'

          Finished in 2.42 seconds (files took 0.14302 seconds to load)
          4 examples, 2 failures

          Failed examples:

          rspec ./spec/something_spec.rb:1 # Main spec first failure
          rspec ./spec/something_spec.rb:2 # Main spec second failure

          →
        END

        expected = [
          [:start],
          [:failure, <<~END, 0],
            1) Main spec first failure
               Failure/Error
                 First error message
                 is on two lines
               # ./first/one.rb:1:in `first'
               # ./first/two.rb:2:in `block in first'
               # -e:1:in `<main>'
          END
          [:failure, <<~END, 1],
            2) Main spec second failure
               Failure/Error: 1.should eq 2

                 expected: 2
                      got: 1

                 (compared using ==)
               # ./second/one.rb:1:in `second'
               # -e:1:in `<main>'
          END
          [:run_completed, 2, 4],
          [:rerun_failed, 'rspec ./spec/something_spec.rb:1 # Main spec first failure', 0],
          [:rerun_failed, 'rspec ./spec/something_spec.rb:2 # Main spec second failure', 1],
          [:finished],
        ]

        events.should eq expected
        stalker_events.should match [
          {
            title: 'RSpec had 2 failed spec(s)',
            status: :failure,
            beholder: :rspec,
            quickfix: <<~END,
              spec/something_spec.rb:1 Main spec first failure
              spec/something_spec.rb:2 Main spec second failure
            END
            failures: [
              "first/one.rb:1 in `first'\nfirst/two.rb:2 in `block in first'\n",
              "second/one.rb:1 in `second'\n",
            ],
            rerun: 'rspec ./spec/something_spec.rb:1 ./spec/something_spec.rb:2',
          },
        ]
      end

      it 'handles two consecutive runs' do
        behold <<~END
          → rspec --format documentation spec/spec_someting_spec.rb
          Running via Spring preloader in process 12345
          .F.F

          Main spec
            failure (FAILED - 1)

          Failures:

            1) Main failure
               Failure/Error

               # -e:1:in `<main>'

          Finished in 2.42 seconds (files took 0.14302 seconds to load)
          2 examples, 1 failure

          Failed examples:

          rspec ./spec/something_spec.rb:1 # Main spec first failure

          → rspec --format documentation spec/spec_someting_spec.rb
          ..
          Finished in 2.42 seconds (files took 0.14302 seconds to load)
          2 examples, 0 failures

          →
        END

        expected = [
          [:start],
          [:failure, <<~END, 0],
            1) Main failure
               Failure/Error

               # -e:1:in `<main>'
          END
          [:run_completed, 1, 2],
          [:rerun_failed, 'rspec ./spec/something_spec.rb:1 # Main spec first failure', 0],
          [:finished],

          [:start],
          [:run_completed, 0, 2],
          [:finished],
        ]

        events.should eq expected

        stalker_events.should match [
          a_hash_including(
            quickfix: "spec/something_spec.rb:1 Main spec first failure\n",
            rerun: 'rspec ./spec/something_spec.rb:1',
          ),
          a_hash_including(
            title: 'RSpec ran successfully',
            status: :success,
            quickfix: '',
            rerun: '',
          ),
        ]
      end
    end
  end
end
