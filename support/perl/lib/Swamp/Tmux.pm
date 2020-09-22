package Swamp::Tmux;

use v5.30;
use warnings;

use Exporter 'import';
use Term::ANSIColor qw( colorstrip );
use Carp qw( croak );

our @EXPORT_OK = qw( tmux_parse_list_keys tmux_parse_docs );

sub tmux_parse_list_keys {
  my ( $list_keys_output, $docs ) = @_;

  my $result = {};

  for ( split( /\n/, $list_keys_output ) ) {
    if ( /^bind-key \s+ (-r)? \s+ -T \s+ (\S+) \s+ (\S+) \s+ (.*)$/x ) {
      my $repeatable = ('-r' eq ($1 || ''));
      my $keymap = $2;
      my $key = $3;
      my $action = $4;

      my ( $command ) = split( ' ', $action );

      $key = $1 if $key =~ /^\\(.)$/;

      push $result->{$keymap}->@*, { key => $key, action => $action, doc => $docs->{ $command } };

    } else {
      croak "unexpected list-keys input: $_";
    }
  }

  $result;
}

our $man_tmux;

sub tmux_parse_docs {
  $man_tmux ||= colorstrip `MANWIDTH=200 man tmux | col -bx`;

  my $man = $man_tmux;

  my $docs = {};

  $man =~ s/\be\s*\.g\./eg/g;

  while ( $man =~ /
    ^[ ]{5} ([-a-z]+) \N* \n
    (?: [ ]+ \(alias: \N* \n )?
    [ ]{13} ( \N*? (?: \. | \n))
  /xgm ) {
    my $name = $1;
    my $doc = $2;

    $doc =~ s/-?\n/.../;
    $doc =~ s/ +/ /g;

    $docs->{ $name } = $doc;
  }

  $docs;
}

1;
