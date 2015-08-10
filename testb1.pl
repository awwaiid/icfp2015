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


$| = 1;
while(1) {
  open my $log, '>>', '/tmp/mylog.log';

  my $world = <>;
  chomp $world;
  last if ! $world;
  $world = decode_json($world);
  my $real_world = World->thaw_world($world->{me});
  $real_world->move("l");
  say $log $real_world->solution();
  say $log "do it";
  my $json = encode_json($real_world->to_json()); 
  my $bot_cmd = "./worldplay.pl";
  my ($to_bot, $from_bot);
  open2($from_bot, $to_bot, $bot_cmd, $json);
  $to_bot->say("l");

  if(!eof($from_bot)) {
    my $new_world = <$from_bot>;
    $new_world = decode_json($new_world);
    my $real_new_world = World->thaw_world($new_world->{me});
  say $log $real_world->solution();
  }
  die;
}

