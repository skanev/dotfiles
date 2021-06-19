package Swamp::Stalker::Depot;

use v5.32;
use warnings;
use utf8::all;
use experimental qw( signatures );
use autodie;

use Redis;
use JSON qw( encode_json decode_json );
use Time::HiRes qw( time );

use constant PREFIX => 'stalker:';

sub new {
  my ( $class ) = @_;

  my $redis = Redis->new;
  $redis->select( 7 );

  my $self = { redis => $redis };

  return bless $self, $class;
}

sub report( $self, $name, $data ) {
  my $id = time() . "";
  $data->{id} = $id;

  my $encoded = encode_json( $data );
  $self->{redis}->set( PREFIX . $name, $encoded );
  $self->{redis}->set( PREFIX . 'last', $encoded );
  $self->{redis}->set( PREFIX . "runs:$id", $encoded );
  $self->{redis}->expire( PREFIX . "runs:$id", 86400 );
}

sub get( $self, $name ) {
  decode_json $self->{redis}->get( PREFIX . $name );
}

1;
