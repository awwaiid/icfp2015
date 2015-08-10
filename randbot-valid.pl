#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

use JSON::MaybeXS;

# {p, ', !, ., 0, 3}  move W
# {b, c, e, f, y, 2}  move E
# {a, g, h, i, j, 4}  move SW
# {l, m, n, o, space, 5}      move SE
# {d, q, r, v, z, 1}  rotate clockwise
# {k, s, t, u, w, x}  rotate counter-clockwise
# \t, \n, \r  (ignored)

my $moves = '';

#srand(0);

$| = 1;
while(1) {
  my $world = <>;
  chomp $world;
  last if ! $world;
  $world = decode_json($world);
  my @valid_moves = @{$world->{valid_moves}};
  my @legal_moves = @{$world->{legal_moves}};
  # say STDERR "Valid moves: @valid_moves";
  # say STDERR "Legal moves: @legal_moves";

  if(@valid_moves) {
    my $move = $valid_moves[int rand @valid_moves];
    $move = {
      'p' => [qw( p ' ! . 0 3 )]->[int rand 6],
      'b' => [qw( b c e f y 2 )]->[int rand 6],
      'a' => [qw( a g h i j 4 )]->[int rand 6],
      'l' => [qw( l m n o _ 5 )]->[int rand 6],
      'd' => [qw( d q r v z 1 )]->[int rand 6],
      'k' => [qw( k s t u w x )]->[int rand 6]
    }->{$move};
    $move =~ s/_/ /g;
    # say STDERR "*** Doing move: $move";
      # if($move eq 'k') {
      #   exit;
      # }
    $moves .= $move;
    say $move;
  } else {
    if(@legal_moves) {
      my $move = $legal_moves[int rand @legal_moves];
      # say STDERR "*** Doing legal move: $move";
      # if($move eq 'k') {
      #   exit;
      # }
      $moves .= $move;
      say $move;
    } else {
      # say STDERR "Termingating early for lack of choices.";
      # say STDERR "Moves: $moves";
      # die "NO VALID OR LEGAL MOVES!";
      exit;
    }
  }
}

