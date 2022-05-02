require 'spec_helper'

describe Mire do
  describe '#track_hivemind' do
    def track(text)
      io = StringIO.new(text)
      output = []

      Mire.track_hivemind(io) do |bus|
        bus.listen(
          start: -> { output << 'STARTED' },
          error: -> (message) { output << "ERROR in #{message}" },
          finish: -> (errors) { output << (errors.zero? ? 'SUCCESS' : 'FAILURE') },
        )
      end

      output
    end

    it 'parses a standard run' do
      result = track <<~END
        webpack | Type-checking in progress...
        webpack | ERROR in ./a.ts 10:11-19
        webpack | TS01: First
        webpack |   3 | message
        webpack |
        webpack | ERROR in ./b.ts 20:21-29
        webpack | TS02: Second
        webpack |   3 | message
        webpack |
        webpack | Found 2 errors in 100 ms.
      END

      expected = [
        'STARTED',
        'ERROR in ./a.ts 10:11-19 TS01: First',
        'ERROR in ./b.ts 20:21-29 TS02: Second',
        'FAILURE',
      ]

      expected.should eq result
    end

    it 'parses a success' do
      result = track <<~END
        webpack | Type-checking in progress...
        webpack | No errors found.
      END

      expected = [
        'STARTED',
        'SUCCESS',
      ]

      expected.should eq result
    end

    it 'parses a success without an indication that it started' do
      result = track <<~END
        webpack | No errors found.
      END

      expected = [
        'STARTED',
        'SUCCESS',
      ]

      expected.should eq result
    end

    it 'parses two subsequent failures without an starting indication inbetween' do
      result = track <<~END
        webpack | Type-checking in progress...
        webpack | ERROR in ./a.ts 10:11-19
        webpack | TS01: First
        webpack |   3 | message
        webpack |
        webpack | Found 1 error in 100 ms.
        webpack |
        webpack | ERROR in ./b.ts 20:21-29
        webpack | TS02: Second
        webpack |   3 | message
        webpack |
        webpack | Found 1 error in 100 ms.
      END

      expected = [
        'STARTED',
        'ERROR in ./a.ts 10:11-19 TS01: First',
        'FAILURE',
        'STARTED',
        'ERROR in ./b.ts 20:21-29 TS02: Second',
        'FAILURE',
      ]

      expected.should eq result
    end
  end
end

__END__
