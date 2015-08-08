#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

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
    'f' => 'E',
    'a' => 'P',
    'g' => 'R'
  }->{$move};
}

$| = 1;
while(1) {
  my $world = <>; # get the world... and ignore it!
  # say STDERR "WORLD: $world";
  my $move = get_move();
  say $move;
}



