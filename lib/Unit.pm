use Moops;

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
      $x + $self->x_position + (($self->y_position % 2) * ($y % 2)),
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

    # my ($pivot_xx, $pivot_yy, $pivot_zz) = $self->to_xyz($pivot_x, $pivot_y);

    my $position_x = $self->position->[0];
    my $position_y = $self->position->[1];

    my ($position_xx, $position_yy, $position_zz) = $self->to_xyz($position_x, $position_y);
    my ($pivot_xx, $pivot_yy, $pivot_zz) = $self->to_xyz($pivot_x, $pivot_y);

    # say "pivot: $pivot_x, $pivot_y -> $pivot_xx, $pivot_yy, $pivot_zz";

    foreach my $x (keys %{$self->filled}) {
      foreach my $y (keys %{$self->filled->{$x}}) {

        my ($xx, $yy, $zz) = $self->to_xyz($x, $y);

        # Relative position, centered on pivot
        $xx = $xx - $pivot_xx;
        $yy = $yy - $pivot_yy;
        $zz = $zz - $pivot_zz;

        # say "rotate: $xx,$yy,$zz [$x,$y]               "
        #   if $self->orientation;

        for (1..$self->orientation) {
          ($xx, $yy, $zz) = (-$zz, -$xx, -$yy);
          # my $mx = $xx + ($zz - ($zz & 1)) / 2;
          # my $my = $zz;
          # say " -> $xx,$yy,$zz [$mx,$my]               ";
        }

        # absolute position
        $xx = $xx + $pivot_xx + $position_xx;
        $yy = $yy + $pivot_yy + $position_yy;
        $zz = $zz + $pivot_zz + $position_zz;

        # print STDERR "$x,$y -> [$xx,$yy,$zz] + [$position_xx,$position_yy,$position_zz] ->";
        # $xx = $xx + $position_xx;
        # $yy = $yy + $position_yy;
        # $zz = $zz + $position_zz;
        # say STDERR " [$xx,$yy,$zz]";

        my ($abs_x, $abs_y) = $self->to_xy($xx, $yy, $zz);

        # say "rotated: $x,$y" if $debug && $self->orientation;

        push @$positions, [
          # This is ... crazy
          # $x + $self->x_position, # + (($self->y_position % 2) * ($y % 2)) - ($self->y_position % 2),
          # $y + $self->y_position
          $abs_x, $abs_y
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

  method historic_position {
    my @positions = @{$self->real_positions};
    join(";", sort map { join(",", @$_) } @positions );
  }


  method save_history {
    my $position = $self->historic_position;
    if($self->history->{$position}) {
      die "Repeated position!";
    }
    $self->history->{$position} = 1;
  }


  # {p, ', !, ., 0, 3}  move W
  # {b, c, e, f, y, 2}  move E
  # {a, g, h, i, j, 4}  move SW
  # {l, m, n, o, space, 5}      move SE
  # {d, q, r, v, z, 1}  rotate clockwise
  # {k, s, t, u, w, x}  rotate counter-clockwise
  # \t, \n, \r  (ignored)
  method move($direction) {
    # say "cur pos: " . $self->x_position . "," . $self->y_position;
    $self->prev_position([ @{ $self->position } ]);

    my $position_x = $self->position->[0];
    my $position_y = $self->position->[1];

    my ($position_xx, $position_yy, $position_zz) = $self->to_xyz($position_x, $position_y);

    # East
    if($direction =~ /^[bcefy2]$/) {
      $position_xx++;
      $position_yy--;

    # West
    } elsif($direction =~ /^[p'!.03]$/) {
      $position_xx--;
      $position_yy++;

    # SE
    } elsif($direction =~ /^[lmno 5]$/) {
      $position_zz++;
      $position_yy--;

    # SW
    } elsif($direction =~ /^[aghij4]$/) {
      $position_zz++;
      $position_xx--;

    # Rotate clockwise
    } elsif($direction =~ /^[dqrvz1]$/) {
      $self->orientation( ($self->orientation + 1) % 6 );

    # Rotate counter-clockwise
    } elsif($direction =~ /^[kstuwx]$/) {
      $self->orientation( ($self->orientation - 1) % 6 );

    } elsif($direction =~ /^[\t\n\r]$/) {
      # ignored

    } else {
      die "Invalid direction '$direction'";
    }

    ($position_x, $position_y) = $self->to_xy($position_xx, $position_yy, $position_zz);
    $self->position([$position_x, $position_y]);

    # say "new pos: " . $self->x_position . "," . $self->y_position
    #   . " rotate " . $self->orientation;
    # $self->save_history;
    # say "history: @{[ keys %{$self->history} ]}";
  }

  method go_back {
    $self->position([ @{ $self->prev_position } ]);
  }

}

