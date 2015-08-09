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

	$move = getMove($myArray['moves']);

	flog (count($myArray['moves']));
	flog($move);
	
	if (strpos($myArray['status'], 'Game Over') !== false) {
		die('Game over');
	}
	print $move . "\n";
}
flog("ended");

function flog ($message) {
	error_log($message . "\n", 3, "/tmp/phperror");
}

function getMove($moves) {

	return array_pop($moves) == 'l' ? 'a' : 'l';
}

