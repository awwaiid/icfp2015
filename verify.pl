#!/usr/bin/env perl

use v5.18;
# use feature qw(signatures);
# no warnings qw(experimental::signatures);

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
  method BUILD($args) {
    $self->fill_from_problem($args->{problem_filled});
  }

  method to_json {
    return {
      width => $self->width,
      height => $self->height,
      filled => $self->filled,
      map => $self->to_array
    };
  }
}

class Unit extends Board {
  use List::Util qw( max );
  has pivot => (is => 'rw');
  has orientation => (is => 'rw', default => 0);
  method guess_width {
    my $x_vals = {};
    # $y_vals = {};
    foreach my $x (keys %{$self->filled}) {
      $x_vals->{$x} = 1;
      # foreach my $y (keys %{$self->filled->{$x}}) {
      #   $x_vals->{$y} = 1;
      # }
    }
    (max keys %$x_vals) + 1; # min is 1
  }

  around to_json {
    return {
      width => $self->width,
      height => $self->height,
      filled => $self->filled,
      map => $self->to_array,
      pivot => $self->pivot,
      orientation => $self->orientation,
    };
  }
}

my $problem_raw = read_file($ARGV[0]);
my $problem = decode_json($problem_raw);

my $solution_raw = read_file($ARGV[0]);
my $solution = decode_json($solution_raw);

# say "size: $problem->{height} x $problem->{width}";
my $source_length = $problem->{sourceLength};
# say "source length: $source_length";

my $board = Board->new(
  width => $problem->{width},
  height => $problem->{height},
  problem_filled => $problem->{filled}
);
# $board->fill_from_problem($problem->{filled});
# dd($board);
say encode_json($board->to_array);

# my $units = [];
# foreach my $problem_unit (@{$problem->{units}}) {
#   my $unit = Unit->new(problem_filled => $problem_unit->{members});
#   say JSON::MaybeXS->new->allow_blessed->encode($unit);
#   dd $unit->to_json;
#   push @$units, $unit;
# }

# foreach my $seed (@{$problem->{sourceSeeds}}) {
#   say "Seed: $seed";
#   LCG::srand($seed);
#   my $source_count = 0;
#   my $unit_count = length($problem->{units});
#   for (0..$source_length) {
#     say "Unit: " . (LCG::rand() % $unit_count);
#   }
# }



# my $problem = decode_json(read_file($ARGV[0]));

# my $rand = LCG->new(seed => 17);
# print "$rand\n" for 1 .. 10;


#my $json_output = encode_json($data_structure);
