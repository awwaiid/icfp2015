#!/usr/bin/env perl
use v5.18;
use World;

=head1 SYNOPSIS

worldplay.pl world
  world a json representation of a world

one can then feed moves from std in and recieve a world back from
standard out

=cut

my $worlddata = "@ARGV"; #get our world object
chomp $worlddata;
last if ! $worlddata;
$worlddata = decode_json($worlddata);
my $world = World->new(
  problem_id    => $worlddata->problem_id   ,
  version_tag   => $worlddata->version_tag  ,
  seed          => $worlddata->seed         ,
  power_phrases => $worlddata->power_phrases,
  board         => $worlddata->board        ,
  units         => $worlddata->units        ,
  source_count  => $worlddata->source_count ,
  source_length => $worlddata->source_length,
);

foreach my $move (@{$worlddata->{moves}}) {
  $world->move($move);
}
while(1) {
  my $move = <>; # get the world... and ignore it!
  $world->move($move);
  say $world->to_json();
}
