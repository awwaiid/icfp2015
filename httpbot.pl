#!/usr/bin/env perl

use v5.18;
use File::Basename;
use File::Spec;
my $dirname;
BEGIN { $dirname = dirname(File::Spec->rel2abs( __FILE__ )) }
use lib "$dirname/local/lib/perl5";
use lib "$dirname/lib";

use JSON::MaybeXS;
use Continuity;
use IPC::Open2;
$| = 1;

my ($to_bot, $from_bot);
my $bot_cmd = shift @ARGV;
if($bot_cmd) {
  open2($from_bot, $to_bot, $bot_cmd, @ARGV);
}

my $server = Continuity->new(
  debug_level => 0,
  port => 8080,
  cookie_session => 0,
  path_session => 0,
  ip_session => 1,
  no_content_type => 1,
);
$server->loop;

sub main {
  my ($request) = @_;
  my $move;
  while(1) {
    my $world = <>;
    $request->print(
      "Cache-Control: private, no-store, no-cache\r\n",
      "Pragma: no-cache\r\n",
      "Expires: 0\r\n",
      "Access-Control-Allow-Origin: *\r\n",
      "Content-type: application/json\r\n",
      "\r\n"
    );
    $request->print($world);
    $request->next;

    while ($request->param('refresh')) {
      $request->print($world);
      $request->next;
    }
    my $steps = $request->param('steps');
    if($bot_cmd && $steps) {
      while($steps) {
        $to_bot->print($world);
        $move = <$from_bot>;
        print $move;
        $steps--;
        $world = <> if $steps > 0;
      }
    } else {
      # No bot, so obey the server
      $move = $request->param('cmd');
      say $move;
    }
  }
}



