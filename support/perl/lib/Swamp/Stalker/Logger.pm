package Swamp::Stalker::Logger;

use v5.32;
use warnings;
use utf8::all;
use experimental qw( signatures );
use autodie;

use Exporter 'import';

our @EXPORT_OK = qw( trace );

sub trace( $message ) {
  chomp $message;
  #say STDERR $message;
}
