#!/usr/bin/env perl -w

use v5.30;
use strict;
use lib::relative "../../lib";
use lib::relative "./support";
use experimental qw( signatures switch );

use Test::More;
use Swamp::Stalker::Surveyors::Rubocop;
use Helpers qw( consume );

my ( $data, $poke ) = consume Swamp::Stalker::Surveyors::Rubocop::surveyor, <<END;
<<END
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
#4 files inspected, 2 offenses detected, 1 offense auto-correctable

is $data->{finished}, 1;
is $data->{failures}->@*, 2;
is $data->{failures}[0]{summary}, 'dir/first.rb:1:2 Lint/UselessAssignment: Useless assignment to variable - foo.';
is $data->{failures}[1]{summary}, 'dir/second.rb:2:3 Layout/ExtraSpacing: Unnecessary spacing detected.';
is $poke->( 'quickfix' ), <<END;
dir/first.rb:1:2 Lint/UselessAssignment: Useless assignment to variable - foo.
dir/second.rb:2:3 Layout/ExtraSpacing: Unnecessary spacing detected.
END
is $poke->( 'rerun' ), 'rubocop dir/first.rb dir/second.rb';

done_testing;
