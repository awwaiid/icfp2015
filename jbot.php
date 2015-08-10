#!/usr/bin/php
<?php
$debut = false;
while ($line = trim(fgets(STDIN))) {
    $world = json_decode($line, true);
    if (!$world || !is_array($world)) {
        die("Bad Json " . json_last_error() . "\n");
    }
    $move = getMove($world);
    if (strpos($world['status'], 'Game Over') !== false) {
        exit;
    }
    flog (mapToDir($move), 'Move');
    move($move);
}
function flog ($message, $header = '') {
    global $debug;
    if (!$debug) {
        return;
    }
    if (is_array($message)) {
        $message = print_r($message, true);
    }
    if ($header) {
        $message = $header . ": " . $message;
    }
    error_log($message . "\n", 3, "/tmp/phperror");
}

function move($move) {
    print $move . "\n";
}

function rotate($world) {
    if (in_array('d', $world['valid_moves'])) {
        return 'd';
    }
    if (in_array('k', $world['valid_moves'])) {
        return 'k';
    }
    else return false;
}

function mapToDir($move) {
    $W = ['p', '\'', '!', '.', '0', '3'];
    $E = ['b', 'c', 'e', 'f', 'y', '2'];
    $SW = ['a', 'g', 'h', 'i', 'j', '4'];
    $SE = ['l', 'm', 'n', 'o', ' ', '5'];
    $R = ['d', 'q', 'r', 'v', 'z', '1'];
    $P = ['k', 's', 't', 'u', 'w', 'x'];

    if (in_array($move, $W)) return 'W';
    if (in_array($move, $E)) return 'E';
    if (in_array($move, $SW)) return 'SW';
    if (in_array($move, $SE)) return 'SE';
    if (in_array($move, $R)) return 'Rotate';
    if (in_array($move, $P)) return 'Counter';
    else return 'Unknown';
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


    if ($totalMoveCount % 3 == 0 && !isBadTriangle($world) && $rotate = rotate($world)) {
        return $rotate;
    }
    $eastOrWest = eastOrWest($world);
    flog ($eastOrWest, 'PreferredDir');
    flog ($validMoves, 'Valid Moves');
    if ($eastOrWest == 'E') {
        // go east
        if (in_array('b', $validMoves)) {
            return 'e';
        }

        if (in_array('l', $validMoves)) {
            return 'l';
        }
        if (in_array('a', $validMoves)) {
            return $lastMove == 'i' ? 'a' : 'i';
        }
        if (in_array('b', $validMoves)) {
            return '!';
        }

    } else {
        // go west
        if (in_array('p', $validMoves)) {
            return '!';
        }
        if (in_array('a', $validMoves)) {
            return $lastMove == 'i' ? 'a' : 'i';
        }
        if (in_array('l', $validMoves)) {
            return 'l';
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

function eastOrWest($world) {
    $firstFilled = [];
    $map = $world['board']['map'];
    foreach ($map as $col => $m) {
        foreach ($m as $row => $l) {
            if ($l == 'F') {
                $firstFilled = [$row, $col];
                break 2;
            }
        }
    }
    if (empty($firstFilled)) {
        return 'S';
    }
    $pos = $world['current_unit']['position'];
    flog ($pos, "Current Unit Pos");
    flog ($firstFilled, "First Filled Pos");
    if ($pos[0] > $firstFilled[0]) {
        return 'E';
    } else if ($pos[0] < $firstFilled[0]) {
        return 'W';
    } else {
        return 'S';
    }

}

function isBadTriangle($world) {

    $currentUnit = $world['current_unit'];
    $filled = $currentUnit['filled'];
    $count = 0;
    foreach ($filled as $f) {
        $count += $f[0];
    }
    return $count == 3;
}



function getFuture($world) {

    $path  = realpath(__DIR__. '/../');
    $problem = 'problems/problem_ '. $world['problem_id'] . '.json';
    $bot = 'jbot.php';
    $cmd = $path . "/verify.pl " . $path . "/" . $problem . " " . $path . "/" . $bot;
    $out = shell_exec($cmd);

    var_dump($cmd);

}








