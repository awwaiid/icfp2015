<?php

	if (isset($_GET['startServer'])) {
		$path  = realpath(__DIR__. '/../');
		$problem = 'problems/problem_0.json';
		$problem = isset($_GET['problem']) ? $_GET['problem'] : $problem;
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
<body style="width:100%; margin:0 auto; background:#a7a09a; padding:0;">
	<div id="wrap" style="
		width:100%;
		margin:0 auto;
		background:#9c9;
	">
		<div id="header" style="
			background:#ddd;
			padding-left:120px;
			padding-bottom: 5px;
		">
			<hr>
			<button onClick="stopServer(); location.reload();">Start Over</button>
			<button onClick="checkServer(true)">Check Server</button>

			<hr>
			<div id="progress"></div>
			<pre id="result">GAME NOT STARTED</pre>
			<div id="url"></div>

			<hr>
			<button onClick="getMap();" value="play">Play</button>
			<button class="nav" onClick="getMap('W');" disabled >W</button>
			<button class="nav" onClick="getMap('E');" disabled >E</button>
			<button class="nav" onClick="getMap('A');" disabled >SW</button>
			<button class="nav" onClick="getMap('F');" disabled >SE</button>
			<button class="nav" onClick="getMap('R');" disabled >Rotate</button>
			<button class="nav" onClick="getMap('P');" disabled >Rotate(counter)</button>
		</div>
		<div id="left" style="
			position:absolute; 
			width=100px; 
			background:#9c9;
		">
			<div>
				<h7>Problems:</h7>
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

    	function getMap(cmd) {

    		if (checkServer() == false) {
    			alert("You have not started the Server");
    			return;
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
			 				 	
			 	var pivot = data.current_unit.pivot_position;

			 	$("#url").html("Last Move: " + move + " Pivot: " + pivot[0] + ',' +pivot[1]);
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
    		$.get("http://localhost:8888/?startServer=1" + qp);
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


    </script>
</body>

