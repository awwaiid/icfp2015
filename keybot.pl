#!/usr/bin/env perl

use v5.18;
use lib 'local/lib/perl5';
use lib 'lib';
use Term::ReadKey;

sub get_move {
  open my $tty, '<', '/dev/tty';
  ReadMode 3, $tty;
  my $move = ReadKey(0, $tty);
  ReadMode 0, $tty;
  chomp $move;
  return {
    's' => 'W',
    'x' => 'A',
    'c' => 'F',
    'f' => 'E'
  }->{$move};
}

$| = 1;
while(1) {
  my $world = <>; # get the world... and ignore it!
  say STDERR "WORLD: $world";
  my $move = get_move();
  say $move;
}



