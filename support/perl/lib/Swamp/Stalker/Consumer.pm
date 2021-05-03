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

our @EXPORT = ();
our @EXPORT_OK = qw( devour line data peek consume bail depot );
our %EXPORT_TAGS = ( DSL => [ qw( line data peek consume bail depot ) ] );

my $active = 0;
my $current = undef;
my $next = undef;
my $eof = 0;
my $data = {};
my $depot = Swamp::Stalker::Depot->new;

sub read_next() {
  return if $eof || defined $next;

  my $raw = <STDIN>;

  if ( ! defined $raw ) {
    $eof = 1;
    $next = [ undef, undef ];

    return;
  }

  my $letter = $active ? "A" : "I";

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
  read_next;

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
  confess unless $active;
  $active = 0
}

sub depot {
  $depot
}

sub use_depot( $value ) {
  $depot = $value
}

sub devour( $depot, $surveyor ) {
  use_depot $depot;

  while ( consume ) {
    if ( $surveyor->begin ) {
      $active = 1;
      $data = $surveyor->blank;
    }

    if ( $active ) {
      $surveyor->process;

      if ( ! $active || $surveyor->finish ) {
        $active = 0;
        $surveyor->complete;
        $data = undef;
      }
    }
  }
}

1;
