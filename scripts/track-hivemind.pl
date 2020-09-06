# You can pipe hivemind to this process and it will update the tmux status bar
# with a status bar fragment that indicates whether it compiles or not.

use v5.30;
use utf8::all;
use strict;
use experimental qw(switch signatures);
use Term::ANSIColor qw(colorstrip);

use constant SUCCESS => '#[bg=colour236,fg=colour82]';
use constant WAITING => '#[bg=colour236,fg=colour243]';
use constant FAILURE => '#[bg=colour124,fg=colour255]';

sub set_status($message) {
  system "tmux set \@info \"$message\""
}

sub clear_status() {
  system 'tmux set -u @info';
}

sub refresh_client() {
  system "tmux refresh-client -S";
}

set_status '⏳';

$SIG{INT} = sub { system 'tmux set -u @info'; };

my $errors = 0;
my $last_failed = 0;

while (<>) {
  print;
  $_ = colorstrip $_;

  next unless /^webpack +\| (.*)$/;

  $_ = $1;

  $errors++ if /^ERROR in/;

  next unless /｢wdm｣: (.*)/;

  given ($1) {
    when('Failed to compile.') {
      $last_failed = 1;
      set_status "${\FAILURE} 💥 $errors";
    }
    when('Compiling...') {
      $errors = 0;
      my $prefix = $last_failed ? FAILURE : WAITING;
      set_status "$prefix …";
    }
    when('Compiled successfully.') {
      $errors = 0;
      $last_failed = 0;
      set_status "${\SUCCESS} ✔︎";
    }
    default { next }
  }
  refresh_client;
}

clear_status;

