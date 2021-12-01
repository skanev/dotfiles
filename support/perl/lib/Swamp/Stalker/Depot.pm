package Swamp::Stalker::Depot;

use v5.32;
use warnings;
use utf8::all;
use experimental qw( signatures );
use Storable qw( dclone );
use autodie;

use Redis;
use POSIX qw( strftime );
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

sub event( $self, $data ) {
  my $now = time();
  my $type = $data->{type};
  my $id = "$type:$now";
  my $timestamp = strftime "%Y-%m-%d %H:%M:%S", localtime( $now );

  $data = dclone( $data );
  $data->{id} = $id;
  $data->{timestamp} = $timestamp;

  $self->{redis}->lpush( PREFIX . 'events', $id );
  $self->{redis}->set( PREFIX . "event:$id", encode_json( $data ) );
  $self->{redis}->expire( PREFIX . "event:$id", 86400 );
}

sub fetch( $self, $event_id ) {
  decode_json $self->{redis}->get( PREFIX . "event:$event_id" );
}

sub clear( $self ) {
  $self->{redis}->del( PREFIX . 'events' );
}

sub events( $self, @types ) {
  my %types = map { $_ => 1 } @types;

  grep { !%types or $types{$_->{type}} }
    map { decode_json $_ }
    grep { $_ }
    map { $self->{redis}->get( PREFIX . "event:$_" ) }
    $self->{redis}->lrange( PREFIX . 'events', 0, 10 );
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
