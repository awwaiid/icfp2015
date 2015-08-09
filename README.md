# icfp2015

The Wrath of Isa

Members: awwaiid, borbyu, e2thex

IRC: irc.freenode.net / #thewrathofisa

Language(s): Perl, PHP, Javascript, Shell

## Game Engine

The game engine lives in verify.pl, and can be invoked directly. It communicates with bots using STDIN/STDOUT.

## Visualizer

To start the php visualizer, run:

    php -S localhost:8888

from the visualizer dir. ( ./visualizer)

Go to http://localhost:8888 in browser

Profit!

## Bots

Bots get a line containing the state-of-the-world via STDIN, and then print their move via STDOUT, and then loop.

* randbot.pl - Just does some random stuff
* keybot.pl - Listents to terminal keyboard input
* httpbot.pl - Exposes the game engine over HTTP. Can wrap another bot.

