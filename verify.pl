#!/usr/bin/env perl

use v5.20;
use lib 'local/lib';
use lib 'lib';
use JSON::MaybeXS;
use File::Slurp;
use LCG;

my $problem_raw = read_file($ARGV[0]);
my $problem = decode_json($problem_raw);

say "size: $problem->{height} x $problem->{width}";
my $source_length = $problem->{sourceLength};
say "source length: $source_length";

foreach my $seed (@{$problem->{sourceSeeds}}) {
  say "Seed: $seed";
  LCG::srand($seed);
  my $source_count = 0;
  my $unit_count = length($problem->{units});
  for (0..$source_length) {
    say "Unit: " . (LCG::rand() % $unit_count);
  }
}



# my $problem = decode_json(read_file($ARGV[0]));

# my $rand = LCG->new(seed => 17);
# print "$rand\n" for 1 .. 10;


#my $json_output = encode_json($data_structure);
