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
use Getopt::Long;
use Storable qw( dclone );

my @old_worlds = ();

# Actual game stuff
use Board;
use Unit;
use World;

our $debug;
our $visualize;
our $seed_option;
our $contest_mode;

Getopt::Long::Configure("bundling");
Getopt::Long::Configure("auto_help");
GetOptions(
  "debug|d"      => \$debug,
  "visualize"    => \$visualize,
  "seed|s=i"     => \$seed_option,
  "contest-mode" => \$contest_mode,
);

=head1 SYNOPSIS

verify.pl [-d] [--visualize] [-s seed] problem.json ./bot

  -d, --debug      Show some debugging output
  --visualize      Draw the state
  -s, --seed S     Set the seed to S
  --contest-mode   Output in the contest format, all seeds

=cut


my $version_tag = `git rev-parse --short HEAD`;
chomp $version_tag;
$version_tag .= "-" . time();

my $problem_raw = read_file(shift @ARGV);
my $problem = decode_json($problem_raw);

foreach my $seed (@{$problem->{sourceSeeds}}) {
  say "Seed: $seed" if $debug;


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

  LCG::srand($seed);
  my $world = World->new(
    game_id       => $problem->{id},
    version_tag   => $version_tag,
    seed          => $seed,
    board         => $board,
    units         => $units,
    source_count  => 0,
    source_length => $problem->{sourceLength},
  );

  my $bot_cmd = "@ARGV";
  my ($to_bot, $from_bot);
  open2($from_bot, $to_bot, $bot_cmd);
  $world->next_unit;

  while(1) {
    $world->viz_map if $visualize;
    say "sending world to bot" if $debug;
    $to_bot->say(encode_json($world->to_json));
    say "getting command from bot" if $debug;
    my $move = <$from_bot>;
    chomp $move;
    if($move eq 'GO BACK') {
      $world = pop @old_worlds;
    } else {
      push @old_worlds, dclone($world);
      my @moves = split(//,$move);
      foreach my $move (@moves) {
        $world->move($move);
      }
    }
    open my $result, '>', 'result.json';
    $result->say(encode_json([$world->to_output_json]));

    if($contest_mode && $world->status ne 'Running') {
      say STDERR "ProblemId: @{[$world->game_id]} Seed: @{[$world->seed]} Score: @{[$world->score]}";
      say encode_json($world->to_output_json);
      last;
    }
  }
}

