#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

use Term::ReadKey;

# {p, ', !, ., 0, 3}  move W
# {b, c, e, f, y, 2}  move E
# {a, g, h, i, j, 4}  move SW
# {l, m, n, o, space, 5}      move SE
# {d, q, r, v, z, 1}  rotate clockwise
# {k, s, t, u, w, x}  rotate counter-clockwise
# \t, \n, \r  (ignored)
sub get_move {
  open my $tty, '<', '/dev/tty';
  ReadMode 3, $tty;
  my $move = ReadKey(0, $tty);
  ReadMode 0, $tty;
  chomp $move;
  return {
    's' => 'p',
    'x' => 'a',
    'c' => 'l',
    'f' => 'b',
    'a' => 'k',
    'g' => 'd',
    'z' => 'GO BACK',
  }->{$move};
}

$| = 1;
while(1) {
  my $world = <>; # get the world... and ignore it!
  # say STDERR "WORLD: $world";
  my $move = get_move();
  say $move;
}



