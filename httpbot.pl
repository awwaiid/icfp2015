#!/usr/bin/env perl

use v5.18;
use lib 'local/lib/perl5';
use lib 'lib';
use JSON::MaybeXS;
use Continuity;
$| = 1;

my $server = Continuity->new(
  debug_level => 2,
  port => 8080,
  cookie_session => 0,
  path_session => 0,
  ip_session => 1,
);
$server->loop;

sub main {
  my ($request) = @_;
  while(1) {
    my $world = <>; # get the world... and ignore it!
    $request->print($world);
    my $move = $request->next->param('cmd');
    say $move;
  }
}



