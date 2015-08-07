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

1;

