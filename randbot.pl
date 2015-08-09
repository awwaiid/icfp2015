#!/usr/bin/env perl

use v5.18;

$| = 1;
while(1) {
  my $world = <>; # get the world... and ignore it!
  # say STDERR "WORLD: $world";
  my $move = { 0 => 'A', 1 => 'F' }->{int rand 2};
  #$move .= { 0 => 'A', 1 => 'F' }->{int rand 2};
  say $move;
}

