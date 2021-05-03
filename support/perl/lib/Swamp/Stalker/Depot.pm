package Swamp::Stalker::Depot;

use v5.32;
use warnings;
use utf8::all;
use experimental qw( signatures );
use autodie;

use Redis;
use JSON qw( encode_json decode_json );

use constant PREFIX => 'stalker:';

sub new {
  my ( $class ) = @_;

  my $redis = Redis->new;
  $redis->select( 7 );

  my $self = { redis => $redis };

  return bless $self, $class;
}

sub report( $self, $name, $data ) {
  $self->{redis}->set( PREFIX . $name, encode_json( $data ) );
}

sub get( $self, $name ) {
  decode_json $self->{redis}->get( PREFIX . $name );
}

1;
