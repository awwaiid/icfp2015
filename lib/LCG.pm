package LCG;
use strict;
use integer;

my $seed = 0;

sub gen_bsd {
  (1103515245 * $seed + 12345) % (1 << 31)
}

sub srand {
  $seed = shift;
}

sub rand {
  my $retval = ($seed & 0xFFFF0000) >> 16;
  $seed = gen_bsd();
  return $retval;
}

sub look_ahead {
  my $count = shift || 1;
  my $saved_seed = $seed;
  my @next_stuff = ();
  push @next_stuff, rand() for 1..$count;
  $seed = $saved_seed;
  return @next_stuff;
}

1;

