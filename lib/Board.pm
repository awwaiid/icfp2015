use Moops;

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

  method to_xyz($x, $y) {
    my $xx = $x - ($y - ($y & 1)) / 2;
    my $zz = $y;
    my $yy = -$xx - $zz;
    return ($xx, $yy, $zz);
  }

  method to_xy($xx, $yy, $zz) {
    my $x = $xx + ($zz - ($zz & 1)) / 2;
    my $y = $zz;
    return ($x, $y);
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

1;

