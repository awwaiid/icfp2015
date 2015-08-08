<?php

	if (isset($_GET['startServer'])) {
		$path  = realpath(__DIR__. '/../');
		$problem = 'problems/problem_0.json';
		$bot = 'httpbot.pl';
		$cmd = "echo '" . $path . "/verify.pl " . $path . "/" . $problem . " " . $path . "/" . $bot . " &' | at now >/dev/null 2>&1";
		echo ($cmd);
		echo (shell_exec($cmd));
		exit;
	}

	if (isset($_GET['checkServer'])) {
		$path  = realpath(__DIR__. '/../');
		$cmd = 'ps aux | grep verify | grep -v grep' ;		
		//echo ($cmd);
		//echo (system($cmd, $returnStatus));
		echo ($returnStatus) ? 'not started' : 'started';
		exit;
	}
?>

<!DOCTYPE html>
<head>
    <title>Hex Player</title>
    <script src="hexagon.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
</head>
<body>
	<hr>
	<button onClick="location.reload()">Start Over</button>
	<button onClick="startServer()">Start Server</button>
		<button onClick="checkServer()">Check Server</button>


	<hr>
	<pre id="result"></pre>
	<div id="url"></div>
	<button onClick="getMap('E');" value="getMap">Get Map</button>
	<hr>
	<button onClick="getMap('W');" >W</button>
	<button onClick="getMap('E');" >E</button>
	<button onClick="getMap('A');" >SW</button>
	<button onClick="getMap('F');" >SE</button>
	<button onClick="getMap('R');" >Rotate</button>
	<button onClick="getMap('P');" >Rotate(counter)</button>
	<hr>
	<canvas id="HexCanvas" width="2000" height="2000"></canvas>
    <script>

    	function getMap(cmd) {

    		if (checkServer() == false) {
    			startServer();
    		}

    		if (cmd == 'undefined') {
    			cmd = 'E';
    		}
	        var req = $.get( "http://localhost:8080/?cmd=" + cmd, function( data ) {
	        	var str = JSON.stringify(data.map, null, false); 
			 	$( "#result" ).html( str);
			 	$("#url").html("http://localhost:8080/?cmd=" + cmd);
			 	var height = data.board.height;
			 	var width = data.board.width;
			 	drawGrid(width, height, data.map);
			}, 'json')
			.fail(function() {
				$("#result").html("GAME OVER");
			});
    	}

    	function drawGrid(width, height, map) {
	        var hexagonGrid = new HexagonGrid("HexCanvas", 20);
    	    hexagonGrid.drawHexGrid(width, height, 50, 50, map, true);
    	}

    	function startServer() {
    		$.get("http://localhost:8888/?startServer=1");
    	}

    	function checkServer() {
    		var started = false
    		$.get("http://localhost:8888/?checkServer=1", function (data) {
    			if (data == 'started') {
    				started = true;
    			} 
    		});
    		return started;
    	}
    </script>
</body>

