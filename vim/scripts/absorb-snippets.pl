#!/usr/bin/env perl

# Weirdly named, but what isn't.
#
# Useful tool for migrating to UltiSnips. UltiSnips supports both snipMate
# format and its own format. It's all and good, but it doesn't provide any
# snippets. Instead, you have to use vim-snippets, which provides the snippets.
# All and good again, but now if you want to edit the snippets, you can't jump
# to a single file that contains them all, because half of them are in the
# snipMate format, and the other in the UltiSnips format.
#
# Because the above is massively annoying, this script converts snipMate format
# to UltiSnips format. Actually, it goes a bit further.
#
# Assuming you've checked out vim-snippets in # ~/.vim/transient/steal-vim-snippets/
# (because why wouldn't you), whenever you call this script with a language
# (say "ruby"), it cats the snippets/ file, attempting to change it to
# UltiSnips format, after which it cats the UltiSnips/ file as well.
#
# VimScript should be defining a command that uses this to populate the
# snippets file.

use v5.32;
use warnings;

use utf8::all;
use autodie;

use File::Path::Expand qw( expand_filename );
use Array::Utils qw( intersect );

unless ( $ARGV[0] ) {
  die "Expected a snippet filetype to try to process";
}

my $dir = '~/.vim/transient/steal-vim-snippets';

if ( ! -d expand_filename( $dir ) ) {
  system "git clone https://github.com/honza/vim-snippets.git $dir"
}

my $lang = $ARGV[0];

my $snipmate = expand_filename "$dir/snippets/$lang.snippets";
my $ulti = expand_filename "$dir/UltiSnips/$lang.snippets";

my @ultisnips;
my @snipmates;

if ( -f $snipmate ) {
  open my $file, '<', $snipmate;

  my $endsnippet = 0;

  while (<$file>) {
    if ( /^\t(.*)$/ ) {
      $_ = $1;

      s/`(.*)`/`!v $1`/g;

      say;
      next;
    } elsif ( /^$/ ) {
      print;
      next
    }

    if ($endsnippet) {
      say "endsnippet\n";
      $endsnippet = 0;
    }

    if ( /^#/ ) {
      print;
    } elsif ( /^snippet (\S+) ?(.*)$/ ) {
      push @snipmates, $1;

      my $description;

      if ($2) {
        $description = $2;
        $description =~ s/"/'/g;
        $description = ' "' . $description . '"';
      } else {
        $description = '';
      }

      say "snippet $1$description";
      $endsnippet = 1;
    } else {
      print "# --: $_";
    }
  }

  if ($endsnippet) {
    say "endsnippet\n";
    $endsnippet = 0;
  }
}

if ( -f $ulti ) {
  open my $file, '<', $ulti;

  while (<$file>) {
    push @ultisnips, $1 if /^snippet (\S+)/;

    print $_;
  }
}

for (intersect(@snipmates, @ultisnips)) {
  say "# DUPLICATE SNIPPET: $_";
}
