#!/usr/bin/env perl

use v5.18;
use lib 'local/lib/perl5';
use lib 'lib';
use JSON::MaybeXS;
use Continuity;
$| = 1;

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
  while(1) {
    my $world = <>; # get the world... and ignore it!
    $request->print(
      "Cache-Control: private, no-store, no-cache\r\n",
      "Pragma: no-cache\r\n",
      "Expires: 0\r\n",
      "Content-type: application/json\r\n",
      "\r\n"
    );
    $request->print($world);
    my $move = $request->next->param('cmd');
    say $move;
  }
}



