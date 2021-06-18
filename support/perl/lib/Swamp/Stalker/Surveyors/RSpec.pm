package Swamp::Stalker::Surveyors::RSpec;

use v5.32;
use warnings;
use experimental qw( signatures switch );

use Carp qw( confess );
use Swamp::Stalker::Surveyor;
use Swamp::Stalker::Consumer qw( :DSL );

sub neat( $value ) {
  chomp $value;
  $value;
}

sub surveyor {
  Swamp::Stalker::Surveyor::surveyor(
    begin => sub { line =~ /^(→ rspec|Failures:|Finished in)/ },
    finish => sub { line =~ /^→ / },
    blank => sub { { failures => [], finished => 0 } },
    process => sub {
      given ( line ) {
        when ( /^  (\d+)\) (.*)$/ ) {
          my ( $number, $name ) = ( $1, $2 );
          my $message = "";

          while ( peek =~ /^(    |$)/ ) {
            $message .= consume;
          }

          push data->{failures}->@*, { number => $number, name => $name, message => $message };
        }

        when ( /^Finished in \S+ seconds?/ ) {
          if ( peek =~ /^\d+ examples?, (\d+) failures?/ ) {
            consume;
            data->{finished} = 1;
            bail if $1 == 0;
          }
        }

        when ( /^Failed examples:/ ) {
          consume while peek =~ /^\s*$/;

          my $i = 0;

          data->{failures}[$i++]{command} = neat consume while peek =~ /^rspec/;

          bail;
        }
      }
    },
    complete => sub( $depot ) {
      my $data = data;
      my @failures = $data->{failures}->@*;

      $data->{result} = {};
      $data->{result}{quickfix} =
        join '',
             map { s/^rspec \.\/(\S+) # (.*)$/$1 $2/r }
             map { "$_->{command}\n" }
             @failures;

      $data->{result}{rerun} = @failures == 0 ? '' :
        "rspec " . join ' ',
             map { s/^rspec (\S+) #.*$/$1/r }
             map { $_->{command} }
             @failures;

      $depot->report( 'rspec', $data );
      $depot->report( 'last', $data );
    },
    poke => sub( $depot, $command = "quickfix", @args ) {
      my $data = $depot->get( 'rspec' );

      if ( $command eq 'quickfix' || $command eq 'rerun' ) {
        $data->{result}{$command};
      } else {
        confess "Unknown poke $command";
      }
    }
  )
}

1;
