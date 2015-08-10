# icfp2015

The Wrath of Isa

Members: awwaiid, borbyu, e2thex

IRC: irc.freenode.net / #thewrathofisa

Language(s): Perl, PHP, Javascript, Python, Shell

## Build / Run

You'll need perl 5.18 and PHP and Python. The ton of perl dependencies get installed into local/ (inside of the project).

    make
    ./play_icfp2015 -f problems/problem_0.json -p word -p of -p power

The output will go to STDOUT, a bit of debugging goes to STDERR.

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
* randbot-verify.pl - Super smart random bot that only does good stuff
* keybot.pl - Listents to terminal keyboard input
* httpbot.pl - Exposes the game engine over HTTP. Can wrap another bot.
* jbot.php - Hand rolled heuristics

