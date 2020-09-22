#!/usr/bin/env perl -w

use v5.30;
use strict;
use lib::relative "../lib";

use Test::More;
use Swamp::ZSH qw( zsh_key );

my %expectations = (
  '^C^X' => 'C-C C-X',
  '^C'   => 'C-C',
  '^[c'  => 'M-c',
  '^[c'  => 'M-c',
);

while (my ($input, $output) = each %expectations) {
  is( zsh_key($input), $output, $input );
}

done_testing();

