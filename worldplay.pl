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
our @power_phrases;
our $time_travel_enabled;
our $ignore_errors;

Getopt::Long::Configure("bundling");
Getopt::Long::Configure("auto_help");
GetOptions(
  "debug|d"      => \$debug,
  "visualize|v"  => \$visualize,
  "seed|s=i"     => \$seed_option,
  "contest-mode" => \$contest_mode,
  "power|p=s"    => \@power_phrases,
  "timetravel|t" => \$time_travel_enabled,
  "noerrors|n"   => \$ignore_errors,
);



=head1 SYNOPSIS

worldplay.pl worldserilized
  world a json representation of a world

one can then feed moves from std in and recieve a world back from
standard out
STDIN          STDOUT
Move --------> newworld
=cut

my $worlddata = "@ARGV"; #get our world object
  open my $log, '>>', '/tmp/mylog.log';
  $worlddata = decode_json($worlddata);
  my $world = World->thaw_world($worlddata->{me});

while(1) {
  my $move = <STDIN>;
  chomp $move;
  if($move eq "reset") {
  }
  else {
    my @moves = split(//,$move);
    foreach my $move (@moves) {
      $world->move($move);
    }
    say encode_json($world->to_json());
  }

}
