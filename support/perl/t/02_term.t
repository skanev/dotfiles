#!/usr/bin/env perl -w

use v5.30;
use strict;
use lib::relative "../lib";

use Test::More;
use Swamp::Term qw( tabularize wrap );

is( tabularize([ [ 'foo', 'bar', 'baz' ], [ 'something', 'a', 'another' ] ], spacing => 1 ), <<END );
foo       bar baz
something a   another
END

is( wrap(' text ', '2'), "\e[2m text \e[0m" );

done_testing();

