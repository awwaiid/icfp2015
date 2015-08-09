
use Test::More;

use v5.18;
use Data::Dump qw(dump);

use Unit;

sub flat_positions {
  my ($positions) = @_;
  $positions = join(' ', sort map { join(",", @$_) } @$positions);
  return $positions;
}

# Simple 2-piece unit with pivot at origin / even
my $unit = Unit->new(
  problem_filled => [
    {x=>0,y=>0}, {x=>1,y=>0}
  ],
  pivot => [0,0]
);

is flat_positions($unit->real_positions), "0,0 1,0";
$unit->move('E');
is flat_positions($unit->real_positions), "1,0 2,0";
$unit->move('E');
is flat_positions($unit->real_positions), "2,0 3,0";
$unit->move('F');
is flat_positions($unit->real_positions), "2,1 3,1";
$unit->move('F');
is flat_positions($unit->real_positions), "3,2 4,2";
$unit->move('R');
is flat_positions($unit->real_positions), "3,2 3,3";
$unit->move('R');
is flat_positions($unit->real_positions), "2,3 3,2";
$unit->move('R');
is flat_positions($unit->real_positions), "2,2 3,2";
$unit->move('R');
is flat_positions($unit->real_positions), "2,1 3,2";
$unit->move('R');
is flat_positions($unit->real_positions), "3,1 3,2";
$unit->move('R');
is flat_positions($unit->real_positions), "3,2 4,2";



# Simple 2-piece unit with pivot at second location
my $unit = Unit->new(
  problem_filled => [
    {x=>0,y=>0}, {x=>1,y=>0}
  ],
  pivot => [1,0]
);

is flat_positions($unit->real_positions), "0,0 1,0";
$unit->move('E');
is flat_positions($unit->real_positions), "1,0 2,0";
$unit->move('E');
is flat_positions($unit->real_positions), "2,0 3,0";
$unit->move('F');
is flat_positions($unit->real_positions), "2,1 3,1";
$unit->move('R');
is flat_positions($unit->real_positions), "3,0 3,1";
$unit->move('R');
is flat_positions($unit->real_positions), "3,1 4,0";

my $unit = Unit->new(
  problem_filled => [
    {x=>0,y=>0}, {x=>1,y=>0}
  ],
  pivot => [0,1]
);

is flat_positions($unit->real_positions), "0,0 1,0";
$unit->move('E');
is flat_positions($unit->real_positions), "1,0 2,0";
$unit->move('R');
is flat_positions($unit->real_positions), "2,0 2,1";
$unit->move('R');
is flat_positions($unit->real_positions), "2,1 2,2";
$unit->move('R');
is flat_positions($unit->real_positions), "1,2 2,2";

my $unit = Unit->new(
  problem_filled => [
    {x=>1,y=>0},
    {x=>0,y=>1},
    {x=>0,y=>2},
  ],
  pivot => [0,0]
);

is flat_positions($unit->real_positions), "0,1 0,2 1,0";
$unit->move('E');
is flat_positions($unit->real_positions), "1,1 1,2 2,0";

my $unit = Unit->new(
  problem_filled => [
    {x=>2,y=>0},
    {x=>1,y=>1},
    {x=>1,y=>2},
    {x=>0,y=>3},
    {x=>0,y=>4}
  ],
  # pivot => [1,2]
  pivot => [0,0]
);


is flat_positions($unit->real_positions), "0,3 0,4 1,1 1,2 2,0";
$unit->move('E');
is flat_positions($unit->real_positions), "1,3 1,4 2,1 2,2 3,0";

done_testing();


