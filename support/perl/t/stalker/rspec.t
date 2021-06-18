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

( $data, $poke ) = consume Swamp::Stalker::Surveyors::RSpec::surveyor, <<END;
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
     # ./app/graphql/graph/types/category_type.rb:13:in `display_name'
     # ./app/graphql/graph/types/base_field.rb:16:in `resolve'
     # ./spec/support/graphql_helpers.rb:17:in `block in resolve'
     # ./lib/user_context.rb:25:in `with'
     # ./spec/support/graphql_helpers.rb:9:in `resolve'
     # ./spec/graphql/graph/queries/category_spec.rb:24:in `block (2 levels) in <main>'
     # -e:1:in `<main>'

  2) Main spec second failure
     Failure/Error: 1.should eq 2

       expected: 2
            got: 1

       (compared using ==)
     # ./spec/graphql/graph/queries/category_spec.rb:74:in `block (2 levels) in <main>'
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
is $poke->( 'quickfix' ), <<END;
spec/something_spec.rb:1 Main spec first failure
spec/something_spec.rb:2 Main spec second failure
END
is $poke->( 'rerun' ), 'rspec ./spec/something_spec.rb:1 ./spec/something_spec.rb:2';

( $data, $poke ) = consume Swamp::Stalker::Surveyors::RSpec::surveyor, <<END;
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

done_testing();
