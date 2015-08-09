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
    //$moves = $world['moves'];
    $validMoves = $world['valid_moves'];

    if (in_array('b', $validMoves)) {
        return 'e';
    }

    if (in_array('a', $validMoves)) {
        return 'i';
    }

    if (in_array('l', $validMoves)) {
        return 'l';
    }

    if (in_array('p', $validMoves)) {
        return '!';
    }

    if (in_array('d', $validMoves)) {
        return 'd';
    }
    if (in_array('k', $validMoves)) {
        return 'k';
    }

    return ' ';

}

