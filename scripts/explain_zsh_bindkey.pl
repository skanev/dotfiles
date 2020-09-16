# Formats the output of `bindkey` in zsh to be a bit nicer an include the
# documentation of each command.

# TODO:
# [ ] group failsafes (e.g. M-a and M-A bound on the same key)
# [ ] group duplicates (e.g. C-x u and C_- mapped to undo)
# [ ] Replace some known keys (C-I to <Tab>, ^[OA to Up/Down/Left/Right)
# [ ] Fix some glitches (M-<Space> instead of M- )
# [ ] Don't hardcode MANWIDTH to 120, but infer it instead
# [ ] Don't cut documentation after the first . to handle "e.g." and such

use v5.30;
use utf8::all;
use strict;
use experimental qw(switch signatures);
use Term::ANSIColor qw(colorstrip);
use List::Util qw(max);
use Data::Dumper;

my $man = colorstrip `MANWIDTH=120 man zshzle | col -bx`;
my %widgets;

while ($man =~ /^[ ]{7}([-a-z]+)(?:\n| \(.*\n)\s+([^\n.]*[.\n])/gm) {
  my $widget = $1;
  my $doc = $2;

  $doc =~ s/-?\n/.../;
  $doc =~ s/ +/ /g;

  $widgets{$widget} = $doc;
}

my @commands;

while (<>) {
  if (/^"(.+)" ([-_a-z0-9]+)$/) {
    my $key = $1;
    my $widget = $2;

    $key =~ s/^\^([^[])$/C-\1/g;
    $key =~ s/^\^([^[])(.)$/C-\1 \2/g;
    $key =~ s/^\^([^[])\^(.)$/C-\1 C-\2/g;
    $key =~ s/^\^\[(.)$/M-\1/g;
    $key =~ s/^\^\[\^(.)$/ESC C-\1/g;

    my $doc = $widgets{$widget};

    push @commands, {key => $key, widget => $widget, doc => $doc};
  } else {
    say "--- $_";
  }
}

my $key_length = max map { length $_->{key} } @commands;
my $widget_length = max map { length $_->{widget} } @commands;

sub just ($text, $len, $color) {
  return $color . $text .  (" " x ($len - length($text))) . "\e[0m";
}

for my $cmd (@commands) {
  printf "%s  %s  %s\n", just($cmd->{key}, $key_length, "\e[38;5;110m"),
                         just($cmd->{widget}, $widget_length, "\e[1m"),
                         "\e[38;5;243m" . $cmd->{doc} . "\e[0m";
}
