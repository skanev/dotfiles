#!/usr/bin/env perl -w

use v5.30;
use strict;
use lib::relative "../../lib";
use lib::relative "./support";
use experimental qw( signatures switch );

use Test::More;
use Swamp::Stalker::Surveyors::RSpec;
use Helpers qw( consume );

my $data;
my $poke;
my $mock;

( $data, $poke, $mock ) = consume Swamp::Stalker::Surveyors::RSpec::surveyor, <<END;
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
     # ./second/one.rb:1:in `second`
     # -e:1:in `<main>'

Finished in 2.42 seconds (files took 0.14302 seconds to load)
4 examples, 2 failures

Failed examples:

rspec ./spec/something_spec.rb:1 # Main spec first failure
rspec ./spec/something_spec.rb:2 # Main spec second failure

→
END

is $data->{finished}, 1;
is $data->{failures}->@*, 2;
is $data->{failures}[0]{command}, 'rspec ./spec/something_spec.rb:1 # Main spec first failure';
is $data->{failures}[1]{command}, 'rspec ./spec/something_spec.rb:2 # Main spec second failure';

is $mock->events->@*, 2;

is_deeply $mock->events->[0], {
  type => 'tests',
  runner => 'rspec',
  quickfix => <<END,
spec/something_spec.rb:1 Main spec first failure
spec/something_spec.rb:2 Main spec second failure
END
  rerun => 'rspec ./spec/something_spec.rb:1 ./spec/something_spec.rb:2',
  failures => [
    {
      command => 'rspec ./spec/something_spec.rb:1 # Main spec first failure',
      name => 'Main spec first failure',
      number => 1,
      quickfix => <<END,
first/one.rb:1 in `first'
first/two.rb:2 in `block in first'
END
      message => <<END,
     Failure/Error
       First error message
       is on two lines
     # ./first/one.rb:1:in `first'
     # ./first/two.rb:2:in `block in first'
     # -e:1:in `<main>'

END
    },
    {
      command => 'rspec ./spec/something_spec.rb:2 # Main spec second failure',
      name => 'Main spec second failure',
      number => 2,
      quickfix => <<END,
second/one.rb:1 in `second`
END
      message => <<END
     Failure/Error: 1.should eq 2

       expected: 2
            got: 1

       (compared using ==)
     # ./second/one.rb:1:in `second`
     # -e:1:in `<main>'

END
    }
  ],
};

is_deeply $mock->events->[1], {
  type => 'rerun',
  command => 'rspec ./spec/something_spec.rb:1 ./spec/something_spec.rb:2',
  runner => 'rspec',
};


is $poke->( 'quickfix' ), <<END;
spec/something_spec.rb:1 Main spec first failure
spec/something_spec.rb:2 Main spec second failure
END
is $poke->( 'rerun' ), 'rspec ./spec/something_spec.rb:1 ./spec/something_spec.rb:2';
is $data->{result}{stacktrace}[0], <<END;
first/one.rb:1 in `first'
first/two.rb:2 in `block in first'
END
is $data->{result}{stacktrace}[1], <<END;
second/one.rb:1 in `second`
END

( $data, $poke, $mock ) = consume Swamp::Stalker::Surveyors::RSpec::surveyor, <<END;
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
.
Finished in 2.42 seconds (files took 0.14302 seconds to load)
2 examples, 0 failures

→
END

is $data->{finished}, 1;
is $data->{failures}->@*, 0;
is $data->{result}{quickfix}, '';
is $data->{result}{rerun}, '';

is $mock->events->@*, 4;

is $mock->events->[0]{type}, 'tests';
is $mock->events->[0]{failures}->@*, 1;

is $mock->events->[1]{type}, 'rerun';

is $mock->events->[2]{type}, 'tests';
is $mock->events->[2]{failures}->@*, 0;
is $mock->events->[2]{quickfix}, '';

is $mock->events->[3]{type}, 'rerun';
is $mock->events->[3]{command}, '';

done_testing();
