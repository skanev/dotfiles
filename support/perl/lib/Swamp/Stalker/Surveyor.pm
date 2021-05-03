package Swamp::Stalker::Surveyor;

use v5.32;
use utf8::all;
use warnings;
use experimental qw( signatures );

use Exporter 'import';

our @EXPORT_OK = qw( surveyor );

sub new {
  my ( $class, %opts ) = @_;
  my $self = { opts => { %opts } };

  return bless $self, $class;
}

sub begin( $self )    { $self->{opts}{begin}->() }
sub finish( $self )   { $self->{opts}{finish}->() }
sub process( $self )  { $self->{opts}{process}->() }
sub complete( $self ) { $self->{opts}{complete}->() }
sub blank( $self )    { $self->{opts}{blank}->() }

sub poke( $self, $depot, @args ) {
  $self->{opts}{poke}( $depot, @args );
}

sub surveyor( %opts ) {
  new __PACKAGE__, %opts;
}

1;
