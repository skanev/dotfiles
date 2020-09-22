package Swamp::Term;

use v5.30;
use warnings;

use Exporter 'import';
use List::Util qw( max );
use Term::ANSIColor qw( colorstrip );

our @EXPORT_OK = qw( tabularize wrap );

sub tabularize {
  my ( $data , %opts ) = @_;

  my $spacing = $opts{spacing} || 2;
  my $first = $data->[0] || [];
  my $length = scalar $first->@*;

  my @widths;

  for my $i (0 .. $#{$first} ) {
    $widths[$i] = max map { length colorstrip $_->[$i] } @$data;
  }

  my $output = '';

  for my $row (@$data) {
    for my $i ( 0 .. $#$row ) {
      my $text = $row->[$i];

      $output .= $text;
      $output .= ' ' x ($widths[$i] - length(colorstrip($text)) + $spacing) if $i != $#$row;
    }

    $output .= "\n";
  }

  $output;
}

sub wrap {
  my ( $text, $code ) = @_;

  "\e[${code}m$text\e[0m"
}

1;
