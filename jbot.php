#!/usr/bin/php
<?php
flog("Starting");
while ($line = trim(fgets(STDIN))) {
    flog("Line Length: " . strlen($line));
    $myArray = json_decode($line, true);
    flog($myArray['status']);
    
    if (!$myArray) {
        die("Bad Json " . json_last_error() . "\n");
    }
    //flog(print_r($myArray['moves'], true));

    $move = getMove($myArray);


    flog (count($myArray['moves']));
    flog($move);
    
    if (strpos($myArray['status'], 'Game Over') !== false) {
        die('Game over');
    }
    print $move . "\n";
}
flog("ended");

function flog ($message) {
    //error_log($message . "\n", 3, "/tmp/phperror");
}

function getMove($world) {
    /*
     *
     *  # {p, ', !, ., 0, 3}  move W
        # {b, c, e, f, y, 2}  move E
        # {a, g, h, i, j, 4}  move SW
        # {l, m, n, o, space, 5}      move SE
        # {d, q, r, v, z, 1}  rotate clockwise
        # {k, s, t, u, w, x}  rotate counter-clockwise
        # \t, \n, \r  (ignored)
     */

    $moves = $world['moves'];
    $lastMove = array_pop($moves);
    $validMoves = $world['valid_moves'];

    $totalMoveCount = count($world['moves']);


    if ($totalMoveCount % 3 == 0 && !isBadTriangle($world)) {
        if (in_array('d', $validMoves)) {
            return 'k';
        }
        if (in_array('k', $validMoves)) {
            return 'd';
        }
    }
    if ($world['source_count'] % 2 == 0) {
        // go east
        if (in_array('b', $validMoves)) {
            return 'e';
        }
        if (in_array('a', $validMoves)) {
            return $lastMove == 'i' ? 'a' : 'i';
        }
        if (in_array('l', $validMoves)) {
            return 'l';
        }
        if (in_array('b', $validMoves)) {
            return '!';
        }

    } else {
        // go west
        if (in_array('p', $validMoves)) {
            return '!';
        }
        if (in_array('l', $validMoves)) {
            return 'l';
        }
        if (in_array('a', $validMoves)) {
            return $lastMove == 'i' ? 'a' : 'i';
        }
        if (in_array('b', $validMoves)) {
            return 'e';
        }
    }

    // no valid moves left do a rotate

    if ($world['source_count'] % 2 == 0 && in_array('d', $validMoves)) {
        return 'd';
    }
    if (in_array('k', $validMoves)) {
        return 'k';
    }

    return count($world['legal_moves'])
        ? $world['legal_moves'][0]
        : exit;



}

function lowestOpenSpot($world) {
    
}

function isBadTriangle($world) {
    $currentUnit = $world['current_unit'];
    $filled = $currentUnit['filled'];
    if (count($filled[0]) + count($filled[1]) == 3) {
        //if ($currentUnit['orientation'] > 2) {
            return true;
        //}
    }
}










