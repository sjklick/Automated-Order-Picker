var previous_tile_id;
var bin_tile_div;
var selected_bin_id = 1;
var table_item = [];
var table_quantity = [];

// Create warehouse map.
var warehouse = [];
warehouse[0] = ['X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'];
warehouse[1] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[2] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[3] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[4] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[5] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[6] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[7] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[8] = ['X', '.', '.', '.', '.', '.', '.', '.', '.', 'X'];
warehouse[9] = ['X', 'S', 'X', 'X', 'X', 'X', 'X', 'X', 'X', 'X'];

function onTileClick(tile_div) {
	for (let b=0; b<22; b++) {
		if (bin_tile_div[b].id == tile_div.id) {
			selected_bin_id = b+1;
			break;
		}
	}
}

// Add tile divs to the DOM.
let row, column;
let warehouse_element = document.getElementById("warehouse-div");
for (row=0; row<10; row++) {
	for (column=0; column<10; column++) {
		let tile_div = document.createElement("div");
		tile_div.classList.add("tile");
		tile_div.id = row.toString()+","+column.toString();
		warehouse_element.appendChild(tile_div);
		tile_div.onclick = function(){onTileClick(this)};
	}
}

// Add rows to bin table in the DOM.
let table_element = document.getElementById("bin-table");
for (row=0; row<12; row++) {
	let table_row = document.createElement("tr");
	table_item[row] = document.createElement("td");
	table_quantity[row] = document.createElement("td");
	table_item[row].id = "table-item-"+row.toString();
	table_quantity[row].id = "table-quantity-"+row.toString();
	table_row.appendChild(table_item[row]);
	table_row.appendChild(table_quantity[row]);
	table_element.appendChild(table_row);
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
		} else if (warehouse[row][column] == 'S') {
			tile_div.classList.add("shipping");
		} else {
			tile_div.classList.add("unknown");
		}
	}
}

function updateState() {
	var xhttp = new XMLHttpRequest();
	xhttp.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			let data = JSON.parse(this.responseText);
			// Update current order.
			if (data.order == -1) document.getElementById("order").innerText = "Processing no order.";
			else document.getElementById("order").innerText = "Processing order #"+data.order.toString()+".";
			// Remove old picker positions from display.
			if (typeof previous_tile_id !== "undefined") {
				for (let p=0; p<4; p++) {
					let tile_div = document.getElementById(previous_tile_id[p]);
					tile_div.classList.remove("picker");
					tile_div.innerText = "";
				}
			}
			// Initialize bin tiles.
			if (typeof bin_tile_div === 'undefined') {
				bin_tile_div = [];
				for (let b=0; b<22; b++) {
					let id = data.bin[b].position.row.toString()+","+data.bin[b].position.column.toString();
					bin_tile_div[b] = document.getElementById(id);
					bin_tile_div[b].classList.remove("floor");
					bin_tile_div[b].classList.add("bin");
				}
			}
			// Update old positions for next call.
			// Update picker positions on display.
			previous_tile_id = [];
			for (let p=0; p<4; p++) {
				let id = data.picker[p].position.row.toString()+","+data.picker[p].position.column.toString();				
				previous_tile_id[p] = id;
				let tile_div = document.getElementById(id);
				tile_div.classList.add("picker");
				if (data.picker[p].hasItem) {
					tile_div.innerText = p.toString() + " " + data.picker[p].position.facing + " *\n" + data.picker[p].state;
				} else {
					tile_div.innerText = p.toString() + " " +data.picker[p].position.facing + "\n" + data.picker[p].state;
				}
			}
			// Update bin text.
			for (let b=0; b<22; b++) {
				let id = data.bin[b].position.row.toString()+","+data.bin[b].position.column.toString();
				bin_tile_div[b].innerText = data.bin[b].position.facing + "\n" + data.bin[b].nItems.toString();
			}
			// Set an update request for half a second from now.
			setTimeout(updateState, 500);
		} else if (this.readyState == 4 && this.status != 200) {
			setTimeout(updateState, 500);
		}
	}
	xhttp.overrideMimeType("application/json");
	xhttp.open("GET", "state.json", true);
	xhttp.send();
}

function updateBinTable() {
	var xhttpTable = new XMLHttpRequest();
	xhttpTable.onreadystatechange = function() {
		if (this.readyState == 4 && this.status == 200) {
			let data = JSON.parse(this.responseText);
			document.getElementById("table-bin").innerText = "Bin: " + selected_bin_id.toString();
			for (let i=0; i<12; i++) {
				if (i<data.item.length) {
					table_item[i].innerText = data.item[i].name;
					table_quantity[i].innerText = data.item[i].quantity.toString();
				} else {
					table_item[i].innerText = "";
					table_quantity[i].innerText = "";
				}
			}
			setTimeout(updateBinTable, 500);	
		} else if (this.readyState == 4 && this.status != 200) {
			setTimeout(updateBinTable, 500);
		}
	}
	xhttpTable.overrideMimeType("application/json");
	xhttpTable.open("GET", "bin_"+selected_bin_id.toString()+".json", true);
	xhttpTable.send();
}

// Kick-start updates.
updateState();
updateBinTable();