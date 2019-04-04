var previous_tile_id;

// Create warehouse map.
var warehouse = [];
warehouse[0] = ['X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'];
warehouse[1] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[2] = ['X', '.', '.', 'B', 'B', '.', 'B', 'B', '.', 'X'];
warehouse[3] = ['X', '.', '.', 'B', 'B', '.', 'B', 'B', '.', 'X'];
warehouse[4] = ['X', '.', '.', 'B', 'B', '.', 'B', 'B', '.', 'X'];
warehouse[5] = ['X', '.', '.', '.', '.', '.', 'B', 'B', '.', 'X'];
warehouse[6] = ['X', '.', '.', 'B', 'B', '.', 'B', 'B', '.', 'X'];
warehouse[7] = ['X', '.', '.', 'B', 'B', '.', 'B', 'B', '.', 'X'];
warehouse[8] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[9] = ['X', 'S', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'];

// Add tile divs to the DOM.
let row, column;
let warehouse_element = document.getElementById("warehouse-div");
for (row=0; row<10; row++) {
	for (column=0; column<10; column++) {
		let tile_div = document.createElement("div");
		tile_div.classList.add("tile");
		tile_div.id = row.toString()+","+column.toString();
		warehouse_element.appendChild(tile_div);
	}
}

// Update tile classes.
for (row=0; row<10; row++) {
	for (column=0; column<10; column++) {
		let id = row.toString()+","+column.toString();
		let tile_div = document.getElementById(id);
		if (warehouse[row][column] == '.') {
			tile_div.classList.add("floor");
		} else if (warehouse[row][column] == 'X') {
			tile_div.classList.add("wall");
		} else if (warehouse[row][column] == 'B') {
			tile_div.classList.add("bin");
		} else if (warehouse[row][column] == 'S') {
			tile_div.classList.add("shipping");
		} else {
			tile_div.classList.add("unknown");
		}
	}
}

function updatePickerPositions() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			document.getElementById("status").innerText = "Status: Picker positions received.";
			var data = JSON.parse(this.responseText);
			// Remove old picker positions from display.
			if (typeof previous_tile_id !== "undefined") {
				for (let p=0; p<4; p++) {
					let tile_div = document.getElementById(previous_tile_id[p]);
					tile_div.classList.remove("picker");
					tile_div.innerText = "";
				}
			}
			// Update old positions for next call.
			// Update picker positions on display.
			previous_tile_id = [];
			for (let p=0; p<4; p++) {
				let id = data[p].row.toString()+","+data[p].column.toString();				
				previous_tile_id[p] = id;
				let tile_div = document.getElementById(id);
				tile_div.classList.add("picker");
				tile_div.innerText = p.toString() + " " + data[p].facing + "\n" + data[p].state;
			}
			setTimeout(updatePickerPositions, 500);
		} else if (this.readyState == 4 && this.status != 200) {
			document.getElementById("status").innerText = "Status: Failed to update picker positions.";
			setTimeout(updatePickerPositions, 500);
		}
	}
	xhttp.overrideMimeType("application/json");
	xhttp.open("GET", "pickers.json", true);
	xhttp.send();
}

// Kick-start updates.
updatePickerPositions();
