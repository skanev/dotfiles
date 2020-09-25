#!/usr/bin/env perl
# You can pipe hivemind to this process and it will update the tmux status bar
# with a status bar fragment that indicates whether it compiles or not.
#
# TODO:
# [ ] Croaks on invalid unicode symbols in while(<>) instead of shlurping them
#
# In order to get it working, add the following task in VSCode.
#
#     "tasks": {
#       "version": "2.0.0",
#       "tasks": [
#         {
#           "label": "Track Hivemind",
#           "type": "shell",
#           "isBackground": true,
#           "command": "tail -f -n 0 /tmp/hivemind.log",
#           "problemMatcher": {
#             "owner": "typescript",
#             "fileLocation": [
#               "relative",
#               "<PATH-TO-WORKSPACE-(I-M-SURE-IT-CAN-BE-INFERRED-BUT-I-CANT-FIGURE-OUT-HOW)"
#             ],
#             "pattern": {
#               "regexp": "^ERROR in ([^\\s]+) (\\d+):(\\d+)-(?:(\\d+):)?(\\d+) (\\w+):(.*)$",
#               "file": 1,
#               "line": 2,
#               "column": 3,
#               "endLine": 4,
#               "endColumn": 5,
#               "code": 6,
#               "message": 7
#             },
#             "background": {
#               "activeOnStart": false,
#               "beginsPattern": "^STARTED$",
#               "endsPattern": "^(FAILURE|SUCCESS)$"
#             }
#           }
#         }
#       ]
#     }

use v5.30;
use utf8::all;
use strict;
use experimental qw(switch signatures);
use Term::ANSIColor qw(colorstrip);

use constant SUCCESS => '#[bg=colour236,fg=colour82]';
use constant WAITING => '#[bg=colour236,fg=colour243]';
use constant FAILURE => '#[bg=colour124,fg=colour255]';

open LOG, '>', '/tmp/hivemind.log';

sub tmux($command) {
  system "tmux $command";
}

sub set_status($message) { tmux "set \@info \"$message\""; }
sub clear_status()       { tmux 'set -u @info'; }
sub refresh_client()     { tmux 'refresh-client -S'; }

set_status '⏳';

$SIG{INT} = sub { clear_status };

my $errors = 0;
my $last_failed = 0;
my $log_next_line = 1;

while (<>) {
  print;

  $_ = colorstrip $_;

  next unless /^webpack +\| (.*)$/;

  $_ = $1;

  if (/^ERROR in/) {
    $errors++;
    print LOG "$_ ";
    $log_next_line = 1;
  } elsif ($log_next_line) {
    $log_next_line = 0;

    if (/^SyntaxError: [^:]+: (.*) \((\d+):(\d+)\)/) {
      say LOG "$2:$3-$3 SyntaxError: $1";
    } elsif (/^Module build failed/) {
      say LOG "1:1-2 $_";
    } else {
      say LOG $_;
    }
  }

  next unless /｢wdm｣: (.*)/;

  given ($1) {
    when('Failed to compile.') {
      $last_failed = 1;
      set_status "${\FAILURE} 💥 $errors";
      say LOG 'FAILURE';
    }
    when('Compiling...') {
      $errors = 0;
      my $prefix = $last_failed ? FAILURE : WAITING;
      set_status "$prefix …";
      say LOG 'STARTED';
    }
    when('Compiled successfully.') {
      $errors = 0;
      $last_failed = 0;
      set_status "${\SUCCESS} ✔︎";
      say LOG 'SUCCESS';
    }
    default { next }
  }
  refresh_client;
}

clear_status;
