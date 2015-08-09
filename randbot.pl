#!/usr/bin/env perl

use v5.18;

# {p, ', !, ., 0, 3}  move W
# {b, c, e, f, y, 2}  move E
# {a, g, h, i, j, 4}  move SW
# {l, m, n, o, space, 5}      move SE
# {d, q, r, v, z, 1}  rotate clockwise
# {k, s, t, u, w, x}  rotate counter-clockwise
# \t, \n, \r  (ignored)

$| = 1;
while(1) {
  my $world = <>; # get the world... and ignore it!
  # say STDERR "WORLD: $world";
  my $move = { 0 => 'a', 1 => 'l' }->{int rand 2};
  #$move .= { 0 => 'a', 1 => 'l' }->{int rand 2};
  say $move;
}

