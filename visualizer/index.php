<?php

	if (isset($_GET['startServer'])) {
		$path  = realpath(__DIR__. '/../');
		$problem = 'problems/problem_0.json';
		$bot = 'httpbot.pl';
		$cmd = "echo '" . $path . "/verify.pl " . $path . "/" . $problem . " " . $path . "/" . $bot . " &' | at now >/dev/null 2>&1";
		echo (shell_exec($cmd));
		exit;
	}

	if (isset($_GET['checkServer'])) {
		$path  = realpath(__DIR__. '/../');
		$cmd = 'ps aux | grep verify | grep -v grep' ;		
		system($cmd, $returnStatus);
		echo ($returnStatus) ? 'not started' : 'started';
		exit;
	}

	if (isset($_GET['stopServer'])) {
		$path  = realpath(__DIR__. '/../');
		$cmd = 'killall perl' ;		
		system($cmd, $returnStatus);
		echo ($returnStatus) ? 'not stopped' : 'stopped';
		exit;
	}
?>

<!DOCTYPE html>
<head>
    <title>Hex Player</title>
    <script src="hexagon.js"></script>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/2.1.3/jquery.min.js"></script>
    <script type="text/javascript">
		window.addEventListener("keydown", dealWithKeyboard, false);
		window.addEventListener("keypress", dealWithKeyboard, false);
		 
		function dealWithKeyboard(e) {
		  	switch(e.keyCode) {
		        case 83: 
		        	// s = w
		        	getMap('W');
		            break;
		        case 70:
		            // f = e
		            getMap('E');
		            break;
		        case 88:
		            // x = sw
		            getMap('A');
		            break;
		        case 67:
		            // c = se
		            getMap('F');
		            break;  
		        case 68:
		        	// d = rotate
		        	getMap('R');
		        	break;
		        case 69:
		        	// e = rotate counter
		        	getMap('P');
		        	break;
    		
    		} 
		}
		$('nav').prop('disabled', false);

    </script>
</head>
<body>
	<hr>
	<button onClick="stopServer(); location.reload();">Start Over</button>
	<button onClick="startServer()">Start Server</button>
		<button onClick="checkServer()">Check Server</button>


	<hr>
	<div id="progress"></div>
	<pre id="result">GAME NOT STARTED</pre>
	<div id="url"></div>
	<button onClick="getMap();" value="getMap">Get Map</button>
	<hr>
	<button class="nav" onClick="getMap('W');" disabled >W</button>
	<button class="nav" onClick="getMap('E');" disabled >E</button>
	<button class="nav" onClick="getMap('A');" disabled >SW</button>
	<button class="nav" onClick="getMap('F');" disabled >SE</button>
	<button class="nav" onClick="getMap('R');" disabled >Rotate</button>
	<button class="nav" onClick="getMap('P');" disabled >Rotate(counter)</button>
	<hr>
	<canvas id="HexCanvas" width="2000" height="2000"></canvas>
    <script>

    	function getMap(cmd) {

    		if (checkServer() == false) {
    			startServer();
    		}
    		if (typeof cmd === 'undefined') {
    			var url = "http://localhost:8080";
    		} else {
    			var url = "http://localhost:8080/?cmd=" + cmd;
    		}
	        var req = $.get(url, function(data) {
	        	//var str = JSON.stringify(data.map, null, false); 
			 	
			 	if (cmd == 'F') var move = 'SE';
			 	else if (cmd == 'A') var move = 'SW';
			 	else var move = cmd;
			 	
			 	$("#url").html("Last Move: " + move);
			 	var height = data.board.height;
			 	var width = data.board.width;
			 	var source_count = data.source_count;
			 	var source_length = data.source_length;

			 	$("#progress").html("Progress: " + source_count + "/" + source_length);
			 	drawGrid(width, height, data.map);

			}, 'json')
			.fail(function() {
				$("#result").html("GAME OVER");
				$('nav').prop('disabled', false);
				stopServer();
			})
			.done(function() {
				$("#result").html("IN PROGRESS");
				$(".nav").prop('disabled', false);
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
    			alert(data); 
    		});
    		return started;
    	}

    	function stopServer() {
    		$.get("http://localhost:8888/?stopServer=1");
    	}


    </script>
</body>

