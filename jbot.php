#!/usr/bin/php
<?php
while ($line = trim(fgets(STDIN))) {
    $world = json_decode($line, true);
    if (!$world || !is_array($world)) {
        die("Bad Json " . json_last_error() . "\n");
    }
    $move = getMove($world);
    if (strpos($world['status'], 'Game Over') !== false) {
        exit;
    }
    move($move);
}
function flog ($message) {
    if (is_array($message)) {
        $message = print_r($message, true);
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
    flog ($eastOrWest);
    if ($eastOrWest == 'E') {
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

function eastOrWest($world) {
    $firstFilled = [];
    $map = $world['board']['map'];
    foreach ($map as $row => $m) {
        foreach ($m as $col => $l) {
            if ($l == 'F') {
                $firstFilled = [$row, $col];
            }
        }
    }
    $pos = $world['current_unit']['position'];
    flog ($pos);
    flog ($firstFilled);
    if ($pos[1] < $firstFilled[1]) {
        return 'E';
    } else if ($pos[1] > $firstFilled[1]) {
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










