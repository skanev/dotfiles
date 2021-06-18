package Swamp::Stalker::Consumer;

use v5.32;
use warnings;
use utf8::all;
use experimental qw( signatures );
use autodie;

use Exporter 'import';

use Term::ANSIColor qw( colorstrip );
use Carp qw( confess );
use Swamp::Stalker::Depot;
use IO::Handle;

our @EXPORT = ();
our @EXPORT_OK = qw( devour line data peek consume bail depot );
our %EXPORT_TAGS = ( DSL => [ qw( line data peek consume bail depot ) ] );

my $current = undef;
my $next = undef;
my $eof = 0;
my $data = {};
my $depot;

my $stream = \*STDIN;
my $surveyor = 0;

sub use_stream( $new_stream ) {
  $stream = $new_stream;
  $current = undef;
  $next = undef;
  $data = {};
  $eof = 0;
}

sub read_next() {
  return if $eof || defined $next;

  my $raw = <$stream>;

  if ( ! defined $raw ) {
    $eof = 1;
    $next = [ undef, undef ];

    return;
  }

  $raw =~ s/\r\n/\n/g;

  my $line = colorstrip $raw;
  $next = [ $line, $raw ];
}

sub consume() {
  return undef if $eof;

  read_next;

  $current = $next;
  $next = undef;

  $current->[0];
}

sub line {
  $current->[0];
}

sub data {
  $data;
}

sub peek {
  read_next;
  $next->[0]
}

sub bail {
  confess unless $surveyor;
  $surveyor->complete( $depot );
  $surveyor = 0;
  $data = undef;
}

sub depot {
  $depot
}

sub use_depot( $value ) {
  $depot = $value
}

sub devour( $depot, @surveyors ) {
  use_depot $depot;
  $surveyor = 0;
  $data = undef;

  while ( consume ) {
    if ( !$surveyor ) {
      for my $some ( @surveyors ) {
        if ( $some->begin ) {
          $surveyor = $some;
          $data = $surveyor->blank;
          last;
        }
      }
    }

    $surveyor->process if $surveyor;
    bail if $surveyor && $surveyor->finish;
  }
}

1;
