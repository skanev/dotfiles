package Swamp::ZSH;

use v5.30;
use warnings;

use Exporter 'import';
use Term::ANSIColor qw( colorstrip );
use Carp qw( croak );

our @EXPORT_OK = qw( zsh_key parse_zsh_bindkey parse_zsh_widgets_docs );

use constant KEY_SEQUENCES => {
  '^[OA' => 'Up',
  '^[OB' => 'Down',
  '^[OC' => 'Right',
  '^[OD' => 'Left',

  '^[[A' => 'Up',
  '^[[B' => 'Down',
  '^[[C' => 'Right',
  '^[[D' => 'Left',
};

# TODO: This is a messy function that needs to be rewritten. Maybe tokenize
# keys and the group <ESC> x to M-x.
sub zsh_key {
  my ($mapping) = @_;
  my @keys;

  OUTER: while ($_ = $mapping) {
    my $key;

    for my $k (%{+KEY_SEQUENCES}) {
      if (index($mapping, $k) == 0) {
        push @keys, KEY_SEQUENCES->{$k};
        substr($mapping, 0, length($k)) = '';
        next OUTER;
      }
    }

    if (/^\^\[\[(.+)$/) {
      push @keys, 'Esc', '[';
      $mapping = $1;
      next;
    }

    if (/^\^\[(.+)$/) {
      $key = 'M-';
      $_ = $1;
    }

    if (/^\^(?!\[)(.*)$/) {
      $key .= "C-";
      $_ = $1;
    }

    return undef if /^\^/;

    s/^\\\\\\\\/\\\\/;
    s/^\\//;

    m/^(.)(.*)$/;

    $key .= $1;
    $mapping = $2;

    push @keys, $key;
  }

  return join(' ', @keys);
}

sub parse_zsh_bindkey {
  my ( $io, $widgets_docs ) = @_;

  $widgets_docs ||= {};

  my @commands;

  while ( <$io> ) {
    if ( /^bindkey -R (-M \w+ )?".*"-".*" self-insert$/ ) {
      next;
    } elsif ( /^bindkey (?:-M \w+ )?"(.+)" ([-_a-z0-9]+)$/ and index( $1, '"-"' ) == -1 ) {
      my $key = zsh_key( $1 );
      my $widget = $2;
      my $doc = $widgets_docs->{ $widget };

      push @commands, {key => $key, original => $1, action => $widget, doc => $doc};
    } else {
      croak "Unrecognized bindkey -L line: $_";
    }
  }

  @commands;
}

our $man_zshzle;

sub parse_zsh_widgets_docs {
  my $widgets = {};

  $man_zshzle ||= colorstrip `MANWIDTH=120 man zshzle | col -bx`;

  my $man = $man_zshzle;

  $man =~ s/\be\s*\.g\./eg/g;

  while ($man =~ /^[ ]{7}([-a-z]+)(?:\n| \(.*\n)\s+([^\n.]*[.\n])/gm) {
    my $widget = $1;
    my $doc = $2;

    $doc =~ s/-?\n/.../;
    $doc =~ s/ +/ /g;

    $widgets->{$widget} = $doc;
  }

  $widgets;
}

1;
