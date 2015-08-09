<?php

	if (isset($_GET['startServer'])) {
		$path  = realpath(__DIR__. '/../');
		$problem = 'problems/problem_0.json';
		$problem = isset($_GET['problem']) ? $_GET['problem'] : $problem;
		$bot = 'httpbot.pl';
		$aiBot = 'randbot.pl';
		$aiBot = isset($_GET['aibot']) ? $_GET['aibot'] : $aibot;
		$cmd = "echo 'killall perl' | at now >/dev/null 2>&1";
		shell_exec($cmd);

		$cmd = "echo '" . $path . "/verify.pl -d " . $path . "/" . $problem . " " . $path . "/" . $bot . " " . $path . "/" . $aiBot . " >/tmp/verify.log 2>&1 &' | at now >/dev/null 2>&1";
		echo ($cmd);
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
    <style type="text/css">
    	.problem {
    		width:120px;
    	}
    </style>
</head>
<body style="width:100%; margin:0 auto; background:#a7a09a; padding:0;">
	<div id="wrap" style="
		width:100%;
		margin:0 auto;
		background:#a7a09a;
	">
		<div id="header" style="
			background:#a7a09a;
			padding-left:120px;
			padding-bottom: 5px;
		">
			<hr>
			<button onClick="stopServer(); location.reload();">Start Over</button>
			<button onClick="checkServer(true)">Check Server</button>
			<button onClick="stopServer()">Stop Server</button>
			&nbsp;&nbsp;&nbsp;Bot Name: <input id="aibot" type="text" value="randbot.pl" size=20 />

			<hr>
			<div id="progress"></div>
			<pre id="result">GAME NOT STARTED</pre>
			<div id="url"></div>

			<hr>
			&nbsp;&nbsp;&nbsp;<button class="nav" onClick="getMap('W');" disabled >W</button>
			<button class="nav" onClick="getMap('E');" disabled >E</button>
			<br>
			<button class="nav" onClick="getMap('A');" disabled >SW</button>
			<button class="nav" onClick="getMap('F');" disabled >SE</button>
			<button class="nav" onClick="getMap('R');" disabled >Rotate</button>
			<button class="nav" onClick="getMap('P');" disabled >Rotate(counter)</button>
			<button class="nav" onClick="getMap('1');" disabled >Step</button>			
			<button class="nav" onClick="getMap('100');" disabled >Step 100</button>
			<button id="play" class="nav" onClick="play();" disabled >Play</button>
			<button id="stop" class="nav" onClick="stop();" hidden >Stop</button>

		</div>
		<div id="left" style="
			position:absolute; 
			width=100px; 
			background:#9c9;
		">
			<div>
				<h7><bold>PROBLEMS:</bold></h7>
				<?php 
					$problems = scandir('../problems');
					if (is_array($problems)) {
						foreach ($problems as $problem) {
							if (strpos($problem, 'json')) {
								echo '<br><button width=100 class="problem" onClick="startServer(\'problems/' 
									. $problem 
									. '\');">' . $problem . '</button>';
							}
						}
					}
				?>
			</div>
		</div>
		
		<div id="right" style="margin-left:120px; background:#5a9;">
			
			<hr>
			<canvas id="HexCanvas" width="3000" height="3000"></canvas>
		</div>
	</div>
    <script>

    	var myTimer;
    	function play() {

    		$("#play").prop("hidden", true);    		
    		$("#stop").prop("hidden", false);

    		myTimer = setInterval(function () {
    			getMap(1); 
    		}, 300
    		);

    	}

    	function stop() {
    		clearInterval(myTimer);
    		$("#play").prop("hidden", false);    		
    		$("#stop").prop("hidden", true);
    	}

    	function getMap(cmd) {

    		//if (checkServer() == false) {
    		//	alert("You have not started the Server");
    		//	return;
    		//}
    		if (typeof cmd === 'undefined') {
    			var url = "http://localhost:8080/?refresh=1";
    		} else if (cmd > 0 && cmd < 1000) { 
    			var url = "http://localhost:8080/?steps=" + cmd;
    		} else {		
    			var url = "http://localhost:8080/?cmd=" + cmd;
    		} 
	        var req = $.get(url, function(data) {
	        	//var str = JSON.stringify(data.map, null, false); 
			 	
			 	if (cmd == 'F') var move = 'SE';
			 	else if (cmd == 'A') var move = 'SW';
			 	else var move = cmd;

			 	var moves = data.moves;
			 				 	
			 	var pivot = data.current_unit.pivot_position;
				var score = data.score;
			 	
			 	$("#url").html(
			 		"Last Move: " + move 
			 		+ " Pivot: " + pivot[0] + ',' +pivot[1]
			 		+ " Score: " + score
			 		+ "<br>All Moves " + moves.toString() 
			 		+ "<br>Total Moves: " + moves.length
			 		+ "<br>"
		 		);
			 	var height = data.board.height;
			 	var width = data.board.width;
			 	var source_count = data.source_count;
			 	var source_length = data.source_length;

			 	$("#progress").html("Progress: " + source_count + "/" + source_length);
			 	drawGrid(width, height, data.map, pivot);

			}, 'json')
			.fail(function() {
				$("#result").html("GAME OVER");
				$('.nav').prop('disabled', true);
				stopServer();
				stop();
			})
			.done(function() {
				$("#result").html("IN PROGRESS");
				$(".nav").prop('disabled', false);
			});
    	}

    	function drawGrid(width, height, map, pivot) {
	        var hexagonGrid = new HexagonGrid("HexCanvas", 20);
    	    hexagonGrid.drawHexGrid(width, height, 50, 50, map, pivot, true);
    	}

    	function startServer(problem) {
    		var qp = '';
    		if (typeof problem !== 'undefined') {
    			qp = '&problem=' + problem;
    		} else if ($("#problem").val() != '') {
    			qp = '&problem=' + $("#problem").val();
    		}
    		var bot = $("#aibot").val();
    		qp = qp + '&aibot=' + bot;
    		var req = $.get("http://localhost:8888/?startServer=1" + qp).done(function () { sleep(1000); getMap();});
    	}

    	function checkServer(alert_me) {
    		var started = true
    		$.get("http://localhost:8888/?checkServer=1", function (data) {
    			if (data == 'not started') {
    				started = false;
    			}
    			if (alert_me === true) alert(data); 
    		});
    		return started;
    	}

    	function stopServer() {
    		$.get("http://localhost:8888/?stopServer=1");
    	}

    	function sleep(ms) {
		    var unixtime_ms = new Date().getTime();
		    while(new Date().getTime() < unixtime_ms + ms) {}
		}

		function decodeMove(cmd) {

			var W = ['p', '\'', '!', '.', '0', '3'];	
			var E = ['b', 'c', 'e', 'f', 'y', '2'];	
			var SW = ['a', 'g', 'h', 'i', 'j', '4'];
			var SE = ['l', 'm', 'n', 'o', ' ', '5'];
			var R = ['d', 'q', 'r', 'v', 'z', '1'];	
			var P = ['k', 's', 't', 'u', 'w', 'x'];

			if (W.indexOf(cmd) > -1) return 'W';
			if (E.indexOf(cmd) > -1) return 'E';
			if (SW.indexOf(cmd) > -1) return 'SW';
			if (SE.indexOf(cmd) > -1) return 'SE';
			if (R.indexOf(cmd) > -1) return 'R';
			if (P.indexOf(cmd) > -1) return 'P';

			return '';4
		}
 
    </script>
</body>

