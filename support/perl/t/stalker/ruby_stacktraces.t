#!/usr/bin/env perl -w

use v5.30;
use strict;
use lib::relative "../../lib";
use lib::relative "./support";
use experimental qw( signatures switch );

use Test::More;
use Swamp::Stalker::Surveyors::RubyStacktrace;
use Helpers qw( consume );

# TOP is first
my ( $data, $poke, $mock ) = consume Swamp::Stalker::Surveyors::RubyStacktrace::surveyor, <<END;
→ rake db:reset
rake aborted!
NoMethodError: undefined method `create' for #<Something:0x000000013fa1d160>
/home/stalker/project/file1.rb:10 in `first'
/home/stalker/project/file2.rb:20 in `block in <main>'
/home/stalker/project/file1.rb:15 in `second'
-e:1:in `<main>'
Tasks: TOP => db:reset => db:setup => db:seed
(See full trace by running task with --trace)

END

is $data->{finished}, 1;
is $poke->( 'quickfix' ), <<END;
/home/stalker/project/file1.rb:10 in `first' NoMethodError: undefined method `create' for #<Something:0x000000013fa1d160>
/home/stalker/project/file2.rb:20 in `block in <main>'
/home/stalker/project/file1.rb:15 in `second'
END

is_deeply $mock->events->[0], {
  type => 'stacktrace',
  language => 'ruby',
  quickfix => <<~END
    /home/stalker/project/file1.rb:10 in `first' NoMethodError: undefined method `create' for #<Something:0x000000013fa1d160>
    /home/stalker/project/file2.rb:20 in `block in <main>'
    /home/stalker/project/file1.rb:15 in `second'
    END
};

# TODO Bottom is first
( $data, $poke, $mock ) = consume Swamp::Stalker::Surveyors::RubyStacktrace::surveyor, <<END;
→ rails runner something.rb
Running via Spring preloader in process 55056

Traceback (most recent call last):
         3: from /home/stalker/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/gem-1.0.0/lib/gem/code.rb:30:in `stuff`
         2: from app/file2.rb:20:in `<main>'
         1: from app/file1.rb:10:in `first'
app/top.rb:5:in `location': error message here (SpecificError)
END

is $data->{finished}, 1;
is $poke->( 'quickfix' ), <<END;
app/top.rb:5 in `location': error message here (SpecificError)
app/file1.rb:10 in `first'
app/file2.rb:20 in `<main>'
/home/stalker/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/gem-1.0.0/lib/gem/code.rb:30 in `stuff`
END

is_deeply $mock->events->[0], {
  type => 'stacktrace',
  language => 'ruby',
  quickfix => <<~END
    app/top.rb:5 in `location': error message here (SpecificError)
    app/file1.rb:10 in `first'
    app/file2.rb:20 in `<main>'
    /home/stalker/.rbenv/versions/2.7.2/lib/ruby/gems/2.7.0/gems/gem-1.0.0/lib/gem/code.rb:30 in `stuff`
    END
};

( $data, $poke, $mock ) = consume Swamp::Stalker::Surveyors::RubyStacktrace::surveyor, <<END;
/path/to/one.rb:1:in `initialize': unhandled exception
        from /path/to/two.rb:2:in `new'
        from /path/to/three.rb:3:in `another'
→
END

is_deeply $mock->events->[0], {
  type => 'stacktrace',
  language => 'ruby',
  quickfix => <<~END
    /path/to/one.rb:1 in `initialize': unhandled exception
    /path/to/two.rb:2 in `new'
    /path/to/three.rb:3 in `another'
    END
};

done_testing();
