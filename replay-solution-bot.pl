#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";
$| = 1;

use File::Slurp;
use JSON::MaybeXS;

my $solutions = decode_json(read_file(shift @ARGV));

my $world = <>;
chomp $world;
die "No initial world provided" if ! $world;
$world = decode_json($world);

my $problem_id = $world->{problem_id};
my $seed = $world->{seed};

my $commands = {};
foreach my $solution (@$solutions) {
  $commands
    ->{ $solution->{problemId} }
    ->{ $solution->{seed} } = [ split(//, $solution->{solution}) ];
}

while(1) {
  say shift @{$commands->{$world->{problem_id}}{$world->{seed}}};

  # Then get next world
  my $world = <>;
  chomp $world;
  last if ! $world;
  $world = decode_json($world);
}

