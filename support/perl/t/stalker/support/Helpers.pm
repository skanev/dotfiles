package Helpers;

use v5.32;
use warnings;
use experimental qw( signatures switch );

use Exporter 'import';
use IO::String;
use Swamp::Stalker::Consumer;

our @EXPORT_OK = qw( consume );

package MockDepot {
  sub new( $class ) {
    my $self = bless {}, $class;
  }

  sub report( $self, $name, $data ) {
    $self->{_data} = $data;
  }

  sub data( $self ) {
    $self->{_data};
  }

  sub get( $self, $name ) {
    $self->{_data};
  }
}

sub consume( $surveyor, $output ) {
  my $mock = MockDepot->new;
  my $stream = IO::String->new( $output );

  Swamp::Stalker::Consumer::use_stream $stream;
  Swamp::Stalker::Consumer::devour $mock, $surveyor;

  my $poker = sub { $surveyor->poke( $mock, @_ ) };

  ( $mock->data, $poker );
}

1;
