#!/usr/bin/env perl

# Generate a dim versions of the sonokai colors I can use for perlPOD to distinguish from actual perl code.

use v5.30;
use utf8::all;
use strict;

use List::Util qw(min max);

use Graphics::Color;
use Graphics::Color::RGB;
use Graphics::Color::HSV;

my %codes = (
  Red => 'f85e84',
  Orange => 'ef9062',
  Purple => 'ab9df2',
  Yellow => 'e5c463',
  White => 'ffffff',
  Green => '9ecd6f',
);

while (my ($name, $code) = each %codes) {
  my $hsv = Graphics::Color::RGB->from_hex_string($code)->to_hsv;
  $hsv->value( max(0.0, $hsv->v - 0.12) );
  $hsv->saturation( max(0.0, $hsv->s - 0.13) );
  my $result = $hsv->to_rgb->as_hex_string;
  say "  hi Dim$name guifg=#$result";
}
