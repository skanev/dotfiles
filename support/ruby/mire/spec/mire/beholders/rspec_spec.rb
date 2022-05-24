require 'spec_helper'

module Mire
  module Beholders
    describe Rspec do
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
          [
            :failure,
            <<~END,
              1) Main failure
                 Failure/Error

                 # -e:1:in `<main>'
            END
            0,
          ],
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

      it 'handles pending' do
        behold <<~END
          Subject
            first pending (PENDING: Temporarily skipped with xit)
            (describe)
              passes
              fails (FAILED - 1)
              is pending (PENDING: Temporarily skipped with xit)

          Pending: (Failures listed here are expected and do not affect your suite's status)

            1) Subject first pending
               # Temporarily skipped with xit
               # ./spec/pending.rb:1

            2) Subject (describe) is pending
               # Temporarily skipped with xit
               # ./spec/pending.rb:2


          Failures:

            1) Subject (describe) fails
               Failure
               # ./spec/failure.rb:1:in `method'

          Finished in 0.01716 seconds (files took 0.1462 seconds to load)
          4 examples, 1 failure, 2 pending

          Failed examples:

          rspec ./spec/failure.rb:1 # Subject (describe) fails
        END

        events.should match [
          [:start],
          [:failure, "1) Subject (describe) fails\n   Failure\n   # ./spec/failure.rb:1:in `method'\n", 0],
          [:run_completed, 1, 4],
          [:rerun_failed, 'rspec ./spec/failure.rb:1 # Subject (describe) fails', 0],
          [:finished],
        ]
      end

      it 'handles shared examples' do
        behold <<~END
          .F.

          Failures:


            1) A shared example
               Failure

                 expected: 1
                      got: 2

                 (compared using ==)
               Shared Example Group: "something" called from ./spec/shared_example.rb:2
               # ./spec/actual_example_spec.rb:12:in `something'
               # -e:1:in `<main>'

          Finished in 0.01716 seconds (files took 0.1462 seconds to load)
          3 examples, 1 failure

          Failed examples:

          rspec ./spec/failure.rb:12 # A shared example
        END

        fire_events.should match [
          {
            status: :failure,
            failures: [
              {
                file: 'spec/failure.rb',
                line: 12,
                stacktrace: [
                  ['spec/shared_example.rb', 2, 'in shared example: something'],
                  ['spec/actual_example_spec.rb', 12, "in `something'"],
                ],
                title: 'A shared example',
                message: "   Failure\n\n     expected: 1\n          got: 2\n\n     (compared using ==)\n",
                message_hint: '1 == 2',
              },
            ],
          },
        ]
      end

      describe '(hints)' do
        def hint_for(text)
          Rspec.failure_message_hint(text)
        end

        it 'squashes space on strings it cannot recognize' do
          hint_for(<<~END).should eq 'foo bar baz'
            foo
              bar
            baz
          END
        end

        it 'parses some simple exceptions' do
          hint_for(<<~END).should eq 'ArgumentError: error message'
            Failure/Error: raise ArgumentError.new('error message')

            ArgumentError:
              error message
          END
        end

        it 'parses some comparisons' do
          hint_for(<<~END).should eq '"one" == "two"'
            Failure/Error: actual.should eq expected

              expected: "one"
                   got: "two"

              (compared using ==)
          END

          hint_for(<<~END).should eq '[1] == [2]'
            Failure/Error:
              [1].should eq [
                2
              ]

              expected: [1]
                   got: [2]

              (compared using ==)
          END

          hint_for(
            "  expected: 1\n" \
            "       got: 2\n" \
            "  \n" \
            "  (compared using ==)\n",
          ).should eq '1 == 2'
        end
      end

      describe '(a complicated failure)' do
        let(:output) do
          <<~END
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
          END
        end

        before do
          behold output
        end

        it 'correctly parses beholder events' do
          events.should eq [
            [:start],
            [
              :failure,
              <<~END,
                1) Main spec first failure
                   Failure/Error
                     First error message
                     is on two lines
                   # ./first/one.rb:1:in `first'
                   # ./first/two.rb:2:in `block in first'
                   # -e:1:in `<main>'
              END
              0,
            ],
            [
              :failure,
              <<~END,
                2) Main spec second failure
                   Failure/Error: 1.should eq 2

                     expected: 2
                          got: 1

                     (compared using ==)
                   # ./second/one.rb:1:in `second'
                   # -e:1:in `<main>'
              END
              1,
            ],
            [:run_completed, 2, 4],
            [:rerun_failed, 'rspec ./spec/something_spec.rb:1 # Main spec first failure', 0],
            [:rerun_failed, 'rspec ./spec/something_spec.rb:2 # Main spec second failure', 1],
            [:finished],
          ]
        end

        it 'correctly parses a stalker event' do
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

        it 'correctly parses a fire event' do
          fire_events.should match [
            {
              status: :failure,
              failures: [
                {
                  file: 'spec/something_spec.rb',
                  line: 1,
                  stacktrace: [
                    ['first/one.rb', 1, "in `first'"],
                    ['first/two.rb', 2, "in `block in first'"],
                  ],
                  title: 'Main spec first failure',
                  message: "   Failure/Error\n     First error message\n     is on two lines\n",
                  message_hint: anything,
                },
                {
                  file: 'spec/something_spec.rb',
                  line: 2,
                  stacktrace: [
                    ['second/one.rb', 1, "in `second'"],
                  ],
                  title: 'Main spec second failure',
                  message: "   Failure/Error: 1.should eq 2\n\n     expected: 2\n          got: 1\n\n" \
                           "     (compared using ==)\n",
                  message_hint: anything,
                },
              ],
            },
          ]
        end
      end
    end
  end
end
