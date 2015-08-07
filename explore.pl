#!/usr/bin/env perl

use v5.20;
use lib 'lib';
use JSON::MaybeXS;
use File::Slurp;
use LCG;

# my $problem = decode_json(read_file($ARGV[0]));
# say "$problem->{height} x $problem->{width}";

# my $rand = LCG->new(seed => 17);
# print "$rand\n" for 1 .. 10;

LCG::srand(17);
say LCG::rand() for 1..10;
# 0,24107,16552,12125,9427,13152,21440,3383,6873,16117

