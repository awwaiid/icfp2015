use Moops;

class World {
  has game_id => (is => 'rw');
  has version_tag => (is => 'rw');
  has seed => (is => 'rw');

  has status => (is => 'rw', default => "Running");

  has board => (is => 'rw');
  has units => (is => 'rw');
  has current_unit => (is => 'rw');
  has source_count => (is => 'rw');
  has source_length => (is => 'rw');
  has score => (is => 'rw', default => 0);
  has prev_lines_cleared => (is => 'rw', default => 0);

  has moves => (is => 'rw', default => sub { [] });

  method error($msg) {
    $self->status("Error: $msg");
    $self->score(0);
    die "Error: $msg";
  }

  method game_over($msg) {
    $self->status("Game Over: $msg");
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
      status => $self->status,
      map => $self->map,
      board => $self->board->to_json,
      units => [ map { $_->to_json } @{$self->units} ],
      current_unit => $self->current_unit->to_json,
      source_count => $self->source_count,
      source_length => $self->source_length,
      score => $self->score,
      moves => $self->moves,
      seed => $self->seed,
      valid_moves => $self->valid_moves,
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

  method move($direction) {
    if($self->status eq 'Running') {
      try {
        push @{$self->moves}, $direction;
        my $unit_locs = $self->current_unit->real_positions;
        $self->current_unit->move($direction);
        $self->current_unit->save_history;
        if(! $self->is_position_valid) {
          foreach my $loc (@$unit_locs) {
            $self->board->lock(@$loc);
          }
          $self->board->clear_full_rows;
          $self->addToScore(scalar(@{$self->current_unit->real_positions}), $self->board->getRowsCleared());
          $self->prev_lines_cleared($self->board->getRowsCleared());
          $self->next_unit;
        }
      } catch {
        # $self->error("$_");
      };
    }
  }

  method is_move_valid($direction) {
    $self->current_unit->move($direction);
    my $is_valid = $self->is_position_valid;

    # Check for historic things
    my $position = $self->current_unit->historic_position;
    if($self->current_unit->history->{$position}) {
      $is_valid = 0;
    }

    $self->current_unit->go_back;
    return $is_valid;
  }

  method valid_moves {
    my @moves;
    foreach my $move (qw( p b a l d k )) {
      push @moves, $move if $self->is_move_valid($move);
    }
    return [@moves];
  }

  use Time::HiRes qw( sleep );
  method viz_map {
    my $map = $self->map;
    my $y = 0;
    # print `clear`;
    print "\e[H";
    foreach my $row (@$map) {
      print " " if $y % 2;
      my $x = 0;
      foreach my $col (@$row) {
        print " ";
        print "\e[45m"
          if $x == $self->current_unit->pivot_position->[0]
          && $y == $self->current_unit->pivot_position->[1];
        print $col eq 'E'
        ? "\e[90m◇\e[0m"  # grey
        : $col eq 'F'
        ? "\e[32m◆\e[0m"  # green
        : "\e[91m◆\e[0m"; # red
        $x++;
      }
      print "\n";
      $y++;
    }
    print "\n";
    say "Status: " . $self->status;
    say "Score:  " . $self->score;
    say "Valid moves: " . join("", @{ $self->valid_moves }) . "                 ";
    # sleep 0.25;
  }
}
