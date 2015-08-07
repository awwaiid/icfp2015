#!/usr/bin/env perl

use v5.20;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use lib 'local/lib/perl5';
use lib 'lib';
use JSON::MaybeXS;
use File::Slurp;
use LCG;
use Data::Dump;

use Moops;

# Or ... just use [x,y]
class Cell {
  has x => (is => 'rw');
  has y => (is => 'rw');
}

class Board {
  has width => (is => 'rw');
  has height => (is => 'rw');
  has filled => (is => 'rw');

  method to_array() {
    my $arr = [];
    foreach my $x (0..$self->width) {
      foreach my $y (0..$self->height) {
        $arr->[$y][$x] = $self->filled->{$x}{$y}
          ? "F"
          : "E";
      }
    }
    return $arr;
  }

  method fill_from_problem($filled) {
    $self->filled({});
    foreach my $fill (@$filled) {
      $self
        ->filled
        ->{ $fill->{x} }
        ->{ $fill->{y} } = 1;
    }
  }
}

my $problem_raw = read_file($ARGV[0]);
my $problem = decode_json($problem_raw);

my $solution_raw = read_file($ARGV[0]);
my $solution = decode_json($solution_raw);

say "size: $problem->{height} x $problem->{width}";
my $source_length = $problem->{sourceLength};
say "source length: $source_length";

my $board = Board->new(
  width => $problem->{width},
  height => $problem->{height}
);
$board->fill_from_problem($problem->{filled});
dd($board);
say encode_json($board->to_array);

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
