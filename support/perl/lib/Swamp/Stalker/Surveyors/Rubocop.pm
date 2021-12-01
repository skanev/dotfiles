package Swamp::Stalker::Surveyors::Rubocop;

use v5.32;
use warnings;
use experimental qw( signatures switch );

use Carp qw( confess );
use List::Util qw( uniq );

use Swamp::Stalker::Surveyor;
use Swamp::Stalker::Consumer qw( :DSL );

sub surveyor {
  Swamp::Stalker::Surveyor::surveyor(
    name => 'rubocop',
    begin => sub { line =~ /^(Inspecting \d+ file?|Offenses:)/ },
    finish => sub { line =~ /^→ / },
    blank => sub { { failures => [], finished => 0 } },
    process => sub {
      given ( line ) {
        when ( /^([^: ]+):(\d+):(\d+): (?:[WC]):(?: \[Correctable\])? (.*)$/ ) {
          my ( $file, $line, $column, $message ) = ( $1, $2, $3, $4 );
          my $summary = "$file:$line:$column $message";
          push data->{failures}->@*, { file => $file, line => $line, column => $column, message => $message, summary => $summary };
        }

        when ( /^\d+ files? inspected, (\d+|no) offenses? detected(?:, \d+ offenses? auto-correctable)?$/ ) {
          data->{finished} = 1;
          bail;
        }
      }
    },
    complete => sub( $depot ) {
      my $data = data;
      my @failures = $data->{failures}->@*;

      my $quickfix = join '', map { "$_->{summary}\n" } @failures;
      my $rerun = @failures == 0 ? '' : 'rubocop ' . join ' ', uniq map { $_->{file} } @failures;

      $data->{result} = {};
      $data->{result}{quickfix} = $quickfix;
      $data->{result}{rerun} = $rerun;

      $depot->event({
        type => 'linter',
        linter => 'rubocop',
        quickfix => $quickfix,
        failures => [ map { $_->{summary} } @failures ],
        rerun => $rerun,
      });

      $depot->event({
        type => 'rerun',
        command => $rerun,
      });

      $depot->report( 'rubocop', $data );
    },
    poke => sub( $depot, $command = "quickfix", @args ) {
      my $data = $depot->get( 'rubocop' );

      if ( $command eq 'quickfix' || $command eq 'rerun' ) {
        $data->{result}{$command};
      } else {
        confess "Unknown poke $command";
      }
    }
  )
}

1;
