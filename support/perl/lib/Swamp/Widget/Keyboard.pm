package Swamp::Widget::Keyboard;

use v5.30;
use utf8::all;
use warnings;

use Tickit;
use base 'Tickit::Widget';

my $keyboard = <<'END';
┌─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┬────────┐
│  `  │  1  │  2  │  3  │  4  │  5  │  6  │  7  │  8  │  9  │  0  │  -  │  +  │ delete │
├─────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬─────┤
│ tab    │  q  │  w  │  e  │  r  │  t  │  y  │  u  │  i  │  o  │  p  │  [  │  ]  │  \  │
├────────┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─┬───┴─────┤
│ caps     │  a  │  s  │  d  │  f  │  g  │  h  │  j  │  k  │  l  │  ;  │  '  │  return │
├──────────┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴──┬──┴─────────┤
│ shift       │  z  │  x  │  c  │  v  │  b  │  n  │  m  │  ,  │  .  │  /  │      shift │
├─────┬─────┬─┴───┬─┴────┬┴─────┴─────┴─────┴─────┴─────┼─────┴┬────┴┬────┴┬─────┬─────┤
│ fn  │  ⌃  │  ⌥  │  ⌘   │                              │  ⌘   │  ⌥  │  ◀︎  ├─────┤  ▶︎  │
└─────┴─────┴─────┴──────┴──────────────────────────────┴──────┴─────┴─────┴─────┴─────┘
END

my %colored = ( a => 1, c => 1, delete => 1 );
my %marked = ();
my %clobbered = ();

sub lines { 15 }
sub cols { 90 }

sub render_to_rb {
  my $self = shift;
  my ( $rb, $rect ) = @_;

  my ( $w, $h ) = ( 88, 11 );

  my $win = $self->window;

  $rb->eraserect( $rect );
  my $x = 1;
  my $y = ( $win->cols - $w ) / 2;

  my $highlight = Tickit::Pen->new( fg => 14 );
  my $regular   = Tickit::Pen->new( fg => 244 );
  my $mark      = Tickit::Pen->new( fg => 94 );
  my $clobbered = Tickit::Pen->new( fg => 217 );

  for my $line (split("\n", $keyboard)) {
    $rb->text_at( $x, $y, $line, $regular );

    while ($line =~ /[-a-z0-9`+\\,.\/';\[\]]+/g) {
      if ($clobbered{$&}) {
        $rb->text_at( $x, $y + $-[0], $&, $clobbered );
      } elsif ($colored{$&}) {
        $rb->text_at( $x, $y + $-[0], $&, $highlight );
      } elsif ($marked{$&}) {
        $rb->text_at( $x, $y + $-[0], $&, $mark );
      }
    }

    $x++;
  }
}

sub set {
  my ( $self, %opts ) = @_;

  %colored = map { $_ => 1 } $opts{colored}->@*;
  %marked = map { $_ => 1 } $opts{marked}->@*;
  %clobbered = map { $_ => 1 } $opts{clobbered}->@*;
}

1;
