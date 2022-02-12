package Swamp::Stalker::Surveyors::RubyStacktrace;

use v5.32;
use warnings;
use experimental qw( signatures switch );

use Carp qw( confess );
use List::Util qw( uniq );

use Swamp::Stalker::Surveyor;
use Swamp::Stalker::Consumer qw( :DSL );

sub surveyor {
  Swamp::Stalker::Surveyor::surveyor(
    name => 'ruby_stacktrace',
    begin => sub {
      line =~ /^\w+Error:/ or
        line =~ /^Traceback \(most recent call last\):/ or
        line =~ /^[^ :]+\.rb:\d+:in/
    },
    finish => sub { line =~ /^→/ },
    blank => sub { { locations => [], finished => 0, reversed => 0 } },
    process => sub {
      given ( line ) {
        when ( /^\w+Error: (.*)$/ ) {
          my $message = line;
          my $next = consume;
          $next =~ s/^([^:]+):(\d+):(.*)$/$1:$2 $3/;

          chomp $message;
          chomp $next;

          push data->{locations}->@*, "$next $message";
        }

        when ( /^(\S+):(\d+) (.*)$/ && !data->{reversed} ) {
          push data->{locations}->@*, "$1:$2 $3";
        }

        when ( /^Traceback \(most recent call last\):$/ ) {
          data->{reversed} = 1;
        }

        when ( /^ +(\d+): from (\S+):(\d+):(in .*)$/ ) {
          my ( $number, $filename, $line, $detail ) = ( $1, $2, $3, $4 );
          push data->{locations}->@*, "$filename:$line $detail";

          if ( $number == 1 && consume =~ /^(\S+):(\d+):(.*)$/ ) {
            push data->{locations}->@*, "$1:$2 $3";
            data->{finished} = 1;
            bail;
          }
        }

        when ( /^([^ :]+\.rb):(\d+):(in .*)$/ ) {
          push data->{locations}->@*, "$1:$2 $3";
        }

        when ( /^(?: {8}|\t)from ([^ :]+):(\d+):(.*)$/ ) {
          push data->{locations}->@*, "$1:$2 $3";
        }

        default {
          data->{finished} = 1;
          bail;
        }
      }
    },
    complete => sub( $depot ) {
      my $data = data;
      my @locations = $data->{locations}->@*;

      if ( $data->{reversed} ) {
        @locations = reverse @locations;
      }

      my $quickfix = join '', map { "$_\n" } @locations;

      $data->{result} = {};
      $data->{result}{quickfix} = $quickfix;

      $depot->event({
        type => 'stacktrace',
        language => 'ruby',
        quickfix => $quickfix,
      });

      $depot->report( 'ruby_stacktraces', $data );
    },
    poke => sub( $depot, $command = "quickfix", @args ) {
      my $data = $depot->get( 'ruby_stacktraces' );

      if ( $command eq 'quickfix' ) {
        $data->{result}{quickfix};
      } elsif ( $command eq 'dump' ) {
        say "YOO";
        use Data::Dump qw(dump);
        warn dump $data;
      } else {
        confess "Unknown poke $command";
      }
    }
  )
}

1;
