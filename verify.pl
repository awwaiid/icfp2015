#!/usr/bin/env perl

use v5.18;

use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

use JSON::MaybeXS;
use File::Slurp;
use LCG;
use Data::Dump;
use IPC::Open2;
use Moops;

our $debug = 0;
if($ARGV[0] eq '-d') {
  $debug = 1;
  shift @ARGV;
}


class Board {
  has width => (is => 'rw');
  has height => (is => 'rw');
  has filled => (is => 'rw');
  has rowsCleared => (is => 'rw');

  method map() {
    my $arr = [];
    foreach my $x (0..$self->width-1) {
      foreach my $y (0..$self->height-1) {
        $arr->[$y][$x] = $self->filled->{$x}{$y}
          ? "F"
          : "E";
      }
    }
    return $arr;
  }

  method lock($x, $y) {
    $self->filled->{$x}{$y} = 1;
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
      map => $self->map
    };
  }

  method clear_full_rows {
    $self->rowsCleared(0);
    foreach my $y (0..$self->height-1) {
      my $all_filled = 1;
      foreach my $x (0..$self->width-1) {
        $all_filled &&= $self->filled->{$x}{$y};
      }
      $self->clear_row($y) if $all_filled;
    }
  }

  method getRowsCleared {
    return $self->rowsCleared;
  }

  method clear_row($row) {
    foreach my $y (1..$row) {
      $y = $row - $y + 1;
      foreach my $x (0..$self->width-1) {
        if($self->filled->{$x}{$y-1}) {
          $self->filled->{$x}{$y} = 1;
        } else {
          delete $self->filled->{$x}{$y};
        }
      }
    }

    # Clear the top row
    foreach my $x (0..$self->width-1) {
      delete $self->filled->{$x}{0};
    }
    $self->rowsCleared($self->rowsCleared + 1);

  }

}

class Unit extends Board {
  use List::Util qw( max );

  has pivot => (is => 'rw');
  has orientation => (is => 'rw', default => 0);
  has position => (is => 'rw', default => sub { [0, 0] });
  has prev_position => (is => 'rw', default => sub { [0, 0] });

  # Set of real-position [x, y] for duplicate detection
  has history => (is => 'rw', default => sub { {} });

  method x_position { $self->position->[0] }
  method y_position { $self->position->[1] }

  method reset {
    $self->prev_position([0,0]);
    $self->position([0,0]);
    $self->orientation(0);
    $self->history({});
  }

  method guess_width_height {
    my $x_vals = {};
    my $y_vals = {};
    foreach my $x (keys %{$self->filled}) {
      $x_vals->{$x} = 1;
      foreach my $y (keys %{$self->filled->{$x}}) {
        $x_vals->{$y} = 1;
      }
    }
    $self->width((max keys %$x_vals) + 1); # min is 1
    $self->height((max keys %$y_vals) + 1); # min is 1
  }

  method pivot_position {
    my ($x, $y) = @{ $self->pivot };
    return [
      $x + $self->x_position + (($self->y_position % 2) * ($y % 2)) - ($self->y_position % 2),
      $y + $self->y_position
    ];
  }

  method center_on($width) {
    my $x = int(($width - $self->width) / 2);
    $self->position([$x, 0]);
  }

  method real_positions {
    my $positions = [];

    my $pivot_x = $self->pivot->[0];
    my $pivot_y = $self->pivot->[1];

    my $pivot_xx = $pivot_x - ($pivot_y - ($pivot_y & 1)) / 2;
    my $pivot_zz = $pivot_y;
    my $pivot_yy = -$pivot_xx - $pivot_zz;

    # say "pivot: $pivot_x, $pivot_y -> $pivot_xx, $pivot_yy, $pivot_zz" if $debug;

    foreach my $x (keys %{$self->filled}) {
      foreach my $y (keys %{$self->filled->{$x}}) {
        my $x = $x - $pivot_x;
        my $y = $y - $pivot_y;

        # say "relative: $x,$y" if $debug && $self->orientation;

        my $xx = $x - ($y - ($y & 1)) / 2;
        my $zz = $y;
        my $yy = -$xx - $zz;

        for (1..$self->orientation) {
          # print "rotate: $x,$y -> $xx,$yy,$zz -> ";
          ($xx, $yy, $zz) = (-$zz, -$xx, -$yy);
          my $mx = $xx + ($zz - ($zz & 1)) / 2;
          my $my = $zz;
          # say "$xx,$yy,$zz -> $mx,$my                        ";
        }

        $x = $xx + ($zz - ($zz & 1)) / 2 + $pivot_x;
        $y = $zz + $pivot_y;

        # say "rotated: $x,$y" if $debug && $self->orientation;

        push @$positions, [
          # This is ... crazy
          $x + $self->x_position + (($self->y_position % 2) * ($y % 2)) - ($self->y_position % 2),
          $y + $self->y_position
        ];
      }
    }
    return $positions;
  }

  method BUILD {
    $self->guess_width_height;
  }

  method to_json {
    return {
      width       => $self->width,
      height      => $self->height,
      filled      => $self->filled,
      map         => $self->map,
      pivot       => $self->pivot,
      orientation => $self->orientation,
      position    => $self->position,
      pivot_position    => $self->pivot_position,
      history     => [ map { split(',',$_) } keys %{$self->history} ],
    };
  }

  method save_history {
    my @positions = @{$self->real_positions};
    my $position = join(";", sort map { join(",", @$_) } @positions );
    if($self->history->{$position}) {
      die "Repeated position!";
    }
    $self->history->{$position} = 1;
  }


  # W = west
  # E = east
  # A = South-West
  # F = South-East
  # R = Rotate-clockwise
  # P = Rotate-counter-clockwise
  method move($direction) {
    # say "cur pos: " . $self->x_position . "," . $self->y_position;
    $self->prev_position([ @{ $self->position } ]);
    if($direction eq 'E') {
      $self->position( [ $self->x_position + 1, $self->y_position ]);
    } elsif($direction eq 'W') {
      $self->position( [ $self->x_position - 1, $self->y_position ]);
    } elsif($direction eq 'F') {
      if($self->y_position % 2) {
        $self->position( [ $self->x_position, $self->y_position + 1]);
      } else {
        $self->position( [ $self->x_position + 1, $self->y_position + 1]);
      }
    } elsif($direction eq 'A') {
      if($self->y_position % 2) {
        $self->position( [ $self->x_position - 1, $self->y_position + 1]);
      } else {
        $self->position( [ $self->x_position, $self->y_position + 1]);
      }
    } elsif($direction eq 'R') {
      $self->orientation( ($self->orientation + 1) % 6 );
    } elsif($direction eq 'P') {
      $self->orientation( ($self->orientation - 1) % 6 );
    } else {
      die "Invalid direction '$direction'";
    }
    # say "new pos: " . $self->x_position . "," . $self->y_position . " rotate " . $self->orientation;
    $self->save_history;
    # say "history: @{[ keys %{$self->history} ]}";
  }

  method go_back {
    $self->position([ @{ $self->prev_position } ]);
  }

}

class World {
  has game_id => (is => 'rw');
  has version_tag => (is => 'rw');
  has seed => (is => 'rw');

  has board => (is => 'rw');
  has units => (is => 'rw');
  has current_unit => (is => 'rw');
  has source_count => (is => 'rw');
  has source_length => (is => 'rw');
  has score => (is => 'rw', default => 0);
  has prev_lines_cleared => (is => 'rw', default => 0);

  has moves => (is => 'rw', default => sub { [] });

  method error($msg) {
    $self->score(0);
    die "Error: $msg";
  }

  method game_over($msg) {
    die "Game over: $msg";
  }

  method addToScore ($cell_size, $lines_cleared) {
    my $points = $cell_size + 100 * (1 + $lines_cleared) * $lines_cleared / 2;
    my $line_bonus = 0;
    if ($self->prev_lines_cleared > 1) {
        $line_bonus = int(($self->prev_lines_cleared - 1) * $points / 10);
    } 
    my $score = $points + $line_bonus;
    $self->score($self->score + $score);
  }

  method to_json {
    return {
      map => $self->map,
      board => $self->board->to_json,
      units => [ map { $_->to_json } @{$self->units} ],
      current_unit => $self->current_unit->to_json,
      source_count => $self->source_count,
      source_length => $self->source_length,
      score => $self->score,
    };
  }

  method to_output_json {
    return {
      problemId => $self->game_id,
      tag => $self->version_tag,
      seed => $self->seed,
      solution => join('', @{$self->moves}),
    };
  }

  method unit_count {
    scalar @{ $self->units };
  }

  method next_unit {
    $self->source_count( $self->source_count + 1 );
    if($self->source_count > $self->source_length) {
      $self->game_over("Source exhausted");
    }
    my $unit_num = LCG::rand() % $self->unit_count;
    # say "Unit num: $unit_num";
    my $unit = $self->units->[$unit_num];
    $unit->reset;
    $unit->center_on($self->board->width);
    $self->current_unit($unit);
    if(!$self->is_position_valid) {
      $self->game_over("No room for new unit");
    }
    return $unit;
  }

  method map {
    my $board_map = $self->board->map;
    my $unit_locs = $self->current_unit->real_positions;
    foreach my $loc (@$unit_locs) {
      my ($x, $y) = @$loc;
      $board_map->[$y][$x] = 'U';
    }
    return $board_map;
  }

  method is_position_valid {
    my $board_map = $self->board->map;
    my $unit_locs = $self->current_unit->real_positions;
    foreach my $loc (@$unit_locs) {
      my ($x, $y) = @$loc;
      if($x < 0
        || $x >= $self->board->width
        || $y < 0
        || $y >= $self->board->height
        || $board_map->[$y][$x] ne 'E') {
        return 0;
      }
    }
    return 1;
  }

use Data::Dump;
  # {p, ', !, ., 0, 3}  move W
  # {b, c, e, f, y, 2}  move E
  # {a, g, h, i, j, 4}  move SW
  # {l, m, n, o, space, 5}      move SE
  # {d, q, r, v, z, 1}  rotate clockwise
  # {k, s, t, u, w, x}  rotate counter-clockwise
  # \t, \n, \r  (ignored)
  method denormalize_dir($direction) {
    return {
      W => 'p',
      E => 'b',
      A => 'a',
      F => 'l',
      R => 'd',
      P => 'k'}->{$direction};
  }

  method move($direction) {
    push @{$self->moves}, $self->denormalize_dir($direction);
    my $unit_locs = $self->current_unit->real_positions;
    $self->current_unit->move($direction);
    if(! $self->is_position_valid) {
      foreach my $loc (@$unit_locs) {
        $self->board->lock(@$loc);
      }
      $self->board->clear_full_rows;
      $self->addToScore(scalar(@{$self->current_unit->real_positions}), $self->board->getRowsCleared());
      $self->prev_lines_cleared($self->board->getRowsCleared());
      $self->next_unit;
    }
  }

  use Time::HiRes qw( sleep );
  method viz_map {
    my $map = $self->map;
    my $count = 0;
    # print `clear`;
    print "\e[H";
    foreach my $row (@$map) {
      print " " if $count % 2;
      $count++;
      foreach my $col (@$row) {
        print " ";
        print $col eq 'E'
        ? "\e[90m◇\e[0m"  # grey
        : $col eq 'F'
        ? "\e[32m◆\e[0m"  # green
        : "\e[91m◆\e[0m"; # red
      }
      print "\n";
    }
    print "\n";
    # sleep 0.25;
  }
}

my $problem_raw = read_file($ARGV[0]);
my $problem = decode_json($problem_raw);


# say "size: $problem->{height} x $problem->{width}";

my $board = Board->new(
  width => $problem->{width},
  height => $problem->{height},
  problem_filled => $problem->{filled}
);

my $units = [];
foreach my $problem_unit (@{$problem->{units}}) {
  my $unit = Unit->new(
    problem_filled => $problem_unit->{members},
    pivot => [
      $problem_unit->{pivot}->{x},
      $problem_unit->{pivot}->{y},
    ]);
  push @$units, $unit;
}

my $version_tag = `git rev-parse --short HEAD`;
chomp $version_tag;
$version_tag .= "-" . time();

foreach my $seed (@{$problem->{sourceSeeds}}) {
  say "Seed: $seed" if $debug;
  LCG::srand($seed);
  my $world = World->new(
    game_id => $problem->{id},
    version_tag => $version_tag,
    seed => $seed,
    board => $board,
    units => $units,
    source_count => 0,
    source_length => $problem->{sourceLength},
  );
  my $bot_cmd = $ARGV[1];
  my ($to_bot, $from_bot);
  open2($from_bot, $to_bot, $bot_cmd);
  # print `clear`;
  $world->next_unit;
  while(1) {
    # $world->viz_map if $debug;
    say "sending world to bot" if $debug;
    $to_bot->say(encode_json($world->to_json));
    say "getting command from bot" if $debug;
    my $move = <$from_bot>;
    chomp $move;
    my @moves = split(//,$move);
    foreach my $move (@moves) {
      $world->move($move);
    }
    open my $result, '>', 'result.json';
    $result->say(encode_json([$world->to_output_json]));
  }
  last;
}


# my $problem = decode_json(read_file($ARGV[0]));

# my $rand = LCG->new(seed => 17);
# print "$rand\n" for 1 .. 10;


#my $json_output = encode_json($data_structure);


