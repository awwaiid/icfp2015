// Hex math defined here: http://blog.ruslans.com/2011/02/hexagonal-grid-math.html

function HexagonGrid(canvasId, radius) {
    this.radius = radius;

    this.height = Math.sqrt(3) * radius;
    this.width = 2 * radius;
    this.side = (3 / 2) * radius;


    this.height = 2 * radius;
    this.width = Math.sqrt(3) * radius;
    this.side = (3/2) * radius;

    this.canvas = document.getElementById(canvasId);
    this.context = this.canvas.getContext('2d');
    //this.context.rotate(1);

    this.canvasOriginX = 0;
    this.canvasOriginY = 0;
    
    //this.canvas.addEventListener("mousedown", this.clickEvent.bind(this), false);
};

HexagonGrid.prototype.drawHexGrid = function (rows, cols, originX, originY, map, pivot, isDebug) {
    this.canvasOriginX = originX;
    this.canvasOriginY = originY;

    this.rowLength = rows;
    this.colLength = cols;
    
    var currentHexX;
    var currentHexY;
    var debugText;

    var offsetColumn = false;

    for (var col = 0; col < cols; col++) {
        for (var row = 0; row < rows; row++) {
            color = "#ddd";
            if (!offsetColumn) {
                currentHexY = (col * this.side) + originY;
                currentHexX = (row * this.width) + originX;
            } else {
                currentHexY = col * this.side + originY;
                currentHexX = (row * this.width) + originX + (this.width * 0.5);
            }

            if (isDebug) {
                debugText = row + "," + col;
            }

            var cell = map[col][row];

            if (cell == 'F') {
                color = "#";
            }
            if (cell == 'U') {
                color = "#333";
            }

            if (row == pivot[0] && col == pivot[1]) {
                var ispivot = true;
            } else {
                var ispivot = false;
            }

            this.drawHex(currentHexX, currentHexY, color, debugText, ispivot);
        }
        offsetColumn = !offsetColumn;
    }
};

HexagonGrid.prototype.drawHexAtColRow = function(column, row, color) {
    var drawy = column % 2 == 0 ? (row * this.height) + this.canvasOriginY : (row * this.height) + this.canvasOriginY + (this.height / 2);
    var drawx = (column * this.side) + this.canvasOriginX;

    this.drawHex(drawx, drawy, color, "", false);
};

HexagonGrid.prototype.drawHex = function(x0, y0, fillColor, debugText, pivot) {
    this.context.strokeStyle = "#000";
    this.context.beginPath();
    this.context.moveTo(x0, y0);
    this.context.lineTo(x0 + (this.width / 2), y0 - (this.radius / 2));
    this.context.lineTo(x0 + this.width, y0);
    this.context.lineTo(x0 + this.width, y0 + this.radius);
    this.context.lineTo(x0 + (this.width / 2), y0 + this.radius + (this.radius / 2));
    this.context.lineTo(x0, y0 + this.radius);    

    if (fillColor) {
        this.context.fillStyle = fillColor;
        this.context.fill();
    }

    if (pivot) {
        this.context.beginPath();
        this.context.arc(x0 + (this.width/2), y0 + (this.radius / 2), 5, 0, Math.PI*2, true); 
        this.context.closePath();
        this.context.fillStyle = "red";
        this.context.fill();
//        this.context.fillText("PIVOT", x0 + (this.width / 2) - 7, y0 + (this.radius / 2));
    }

    this.context.closePath();
    this.context.stroke();

    if (debugText) {
        this.context.font = "8px";
        this.context.fillStyle = "#000";
        this.context.fillText(debugText, x0 + (this.width / 2) - 7, y0 + (this.radius / 2));
    }
};

//Recusivly step up to the body to calculate canvas offset.
HexagonGrid.prototype.getRelativeCanvasOffset = function() {
	var x = 0, y = 0;
	var layoutElement = this.canvas;
    if (layoutElement.offsetParent) {
        do {
            x += layoutElement.offsetLeft;
            y += layoutElement.offsetTop;
        } while (layoutElement = layoutElement.offsetParent);
        
        return { x: x, y: y };
    }
}

//Uses a grid overlay algorithm to determine hexagon location
//Left edge of grid has a test to acuratly determin correct hex
HexagonGrid.prototype.getSelectedTile = function(mouseX, mouseY) {

	var offSet = this.getRelativeCanvasOffset();

    mouseX -= offSet.x;
    mouseY -= offSet.y;

    var column = Math.floor((mouseX) / this.side);
    var row = Math.floor(
        column % 2 == 0
            ? Math.floor((mouseY) / this.height)
            : Math.floor(((mouseY + (this.height * 0.5)) / this.height)) - 1);


    //Test if on left side of frame            
    if (mouseX > (column * this.side) && mouseX < (column * this.side) + this.width - this.side) {


        //Now test which of the two triangles we are in 
        //Top left triangle points
        var p1 = new Object();
        p1.x = column * this.side;
        p1.y = column % 2 == 0
            ? row * this.height
            : (row * this.height) + (this.height / 2);

        var p2 = new Object();
        p2.x = p1.x;
        p2.y = p1.y + (this.height / 2);

        var p3 = new Object();
        p3.x = p1.x + this.width - this.side;
        p3.y = p1.y;

        var mousePoint = new Object();
        mousePoint.x = mouseX;
        mousePoint.y = mouseY;

        if (this.isPointInTriangle(mousePoint, p1, p2, p3)) {
            column--;

            if (column % 2 != 0) {
                row--;
            }
        }

        //Bottom left triangle points
        var p4 = new Object();
        p4 = p2;

        var p5 = new Object();
        p5.x = p4.x;
        p5.y = p4.y + (this.height / 2);

        var p6 = new Object();
        p6.x = p5.x + (this.width - this.side);
        p6.y = p5.y;

        if (this.isPointInTriangle(mousePoint, p4, p5, p6)) {
            column--;

            if (column % 2 == 0) {
                row++;
            }
        }
    }

    return  { row: row, column: column };
};


HexagonGrid.prototype.sign = function(p1, p2, p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
};

//TODO: Replace with optimized barycentric coordinate method
HexagonGrid.prototype.isPointInTriangle = function isPointInTriangle(pt, v1, v2, v3) {
    var b1, b2, b3;

    b1 = this.sign(pt, v1, v2) < 0.0;
    b2 = this.sign(pt, v2, v3) < 0.0;
    b3 = this.sign(pt, v3, v1) < 0.0;

    return ((b1 == b2) && (b2 == b3));
};

HexagonGrid.prototype.clickEvent = function (e) {
    var mouseX = e.pageX;
    var mouseY = e.pageY;

    var localX = mouseX - this.canvasOriginX;
    var localY = mouseY - this.canvasOriginY;

    var tile = this.getSelectedTile(localX, localY);
    //alert(tile.column + "-" + tile.row + "-" + this.colLength + "-" + this.rowLength);
    if (tile.column >= 0 && tile.row >= 0 && tile.column < this.colLength && tile.rows < this.rowLength) {
        var drawy = tile.column % 2 == 0 ? (tile.row * this.height) + this.canvasOriginY + 6 : (tile.row * this.height) + this.canvasOriginY + 6 + (this.height / 2);
        var drawx = (tile.column * this.side) + this.canvasOriginX;

        this.drawHex(drawx, drawy - 6, "rgba(110,110,70,0.3)", "", false);
    } 
};

HexagonGrid.prototype.drawPivot = function (x, y) {
    this.drawHex(x, y, 'blue', 'P', true);
};
