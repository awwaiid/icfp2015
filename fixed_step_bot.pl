#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

use File::Slurp;

# This sequence has 1,180 commands (which is why we have not posted it directly
# on this page). It results in a score of 3,261, does not cause an error, and
# does not contain any phrases of power.

my $moves_raw = "iiiiiiiimmiiiiiimimmiiiimimimmimimimimmimimimeemimeeeemimimimimiiiiiimmeemimimimimiimimimmeemimimimmeeeemimimimmiiiiiipmiimimimeeemmimimmemimimimiiiiiimeeemimimimimeeemimimimmiiiimemimimmiiiipimeeemimimmiiiippmeeeeemimimimiiiimmimimeemimimeeeemimimiiiipmeeemmimmiimimmmimimeemimimimmeeemimiiiiipmiiiimmeeemimimiiiipmmiipmmimmiippimemimeeeemimmiipppmeeeeemimimmiimipmeeeemimimiimmeeeeemimmeemimmeeeemimiiippmiippmiiimmiimimmmmmeeeemimmiippimmimimeemimimimmeemimimimmeemimimimiimimimeeemmimimmmiiiiipimeemimimimmiiiimimmiiiiiiiimiimimimimeeemmimimimmiiiiiimimmemimimimimmimimimeemimiiiiiiiimiiiimimimiimimimmimmimimimimmeeeemimimimimmmimimimimeemimimimimmmemimimmiiiiiiimiimimimmiiiiiimeeeeemimimimimmimimimmmmemimimmeeeemimimimmiimimimmiiiiiipmeeeeemimimimimmiiiiimmemimimimimmmmimimmeeeemimimimimeeemimimimmiimimimeeemmimimmiiiiiiimimiiiiiimimmiiiiiiiimmimimimimiiiimimimeemimimimimmeeemimimimimiiiiiiimiiiimimmemimimimmeemimimimeeemmimimmiiiiiimmiiiipmmiiimmmimimeemimimeeemmimmiiiippmiiiimiiippimiimimeemimimeeeemimimiiiipmeemimimiimiimimmimeeemimimmippipmmiimemimmipimeeeemimmeemimiippimeeeeemimimmmimmmeeeemimimiiipimmiipmemimmeeeemimimiipipimmipppimeeemimmpppmmpmeeeeemimmemm";


my @moves = split(//, $moves_raw);


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
  say shift(@moves);
}

