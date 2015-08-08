<?php

if (isset($_GET)) {
	if (isset($_GET['startServer'])) {
		$cmd = '../verify.pl problems/problem_0.json ./httpbot.pl';
		echo 'foobar';
		echo shell_exec($cmd . " &");
	}
	exit;
}

?>

<!DOCTYPE html>
<head>
    <title>Hex</title>
    <script src="hexagon.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
</head>
<body>
	<hr>
	<button onClick="location.reload()">Start Over</button>
	<button onClick="startServer()">Start Server</button>

	<hr>
	<pre id="result"></pre>
	<div id="url"></div>
	<button onClick="getMap();" value="getMap">Get Map</button>
	<hr>
	<button onClick="getMap('W');" >W</button>
	<button onClick="getMap('E');" >E</button>
	<button onClick="getMap('A');" >SW</button>
	<button onClick="getMap('F');" >SE</button>
	<hr>
	<canvas id="HexCanvas" width="2000" height="2000"></canvas>
    <script>

    	function getMap(cmd) {
    		if (cmd == 'undefinded') {
    			cmd = 'E';
    		}
	        $.get( "http://localhost:8080/?cmd=" + cmd, function( data ) {
	        	var str = JSON.stringify(data.map, null, false); 
			 	$( "#result" ).html( str);
			 	$("#url").html("http://localhost:8080/?cmd=" + cmd);
			 	var height = data.board.height;
			 	var width = data.board.width;
			 	drawGrid(width, height, data.map);
			}, 'json');
    	}

    	function drawGrid(width, height, map) {
	        var hexagonGrid = new HexagonGrid("HexCanvas", 20);
    	    hexagonGrid.drawHexGrid(width, height, 50, 50, map, true);
    	}

    	function startServer() {
    		$.get("http://localhost:8888/?startServer=1");
    	}
    </script>
</body>

