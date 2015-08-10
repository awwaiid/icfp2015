#!/usr/bin/php
<?php

while ($line = trim(fgets(STDIN))) {
  flog("GOT[[[" . $line . "]]]\n");
  $myArray = json_decode($line, true);
  flog(print_r($myArray, true));

  // flog("=== Decoded ===");
	// flog(print_r(json_last_error()));
	// flog(print_r($line));
  // flog(print_r($myArray));

  print "l\n";
  $line = trim(fgets(STDIN));
  flog("NEXT LINE GOT[[[" . $line . "]]]\n");

	// flog(print_r($myArray['moves'], true));
	//var_dump ($line);

	// $move = getMove($myArray['moves']);
	// flog($move);

	// print $move . "\n";
}



function flog ($message) {
	error_log($message . "\n", 3, "/tmp/phperror");
}

function getMove($moves) {
	return array_pop($moves) == 'l' ? 'a' : 'l';
	//return 'l';
}

