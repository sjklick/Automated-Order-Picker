#include "order-picker.hpp"
#include <list>
#include <algorithm>

// Forward declarations.
static std::vector<Position> findPath(Position start, Position end, char map[10][10]);

OrderPicker::OrderPicker(Position home) {
    this->home = home;
    current = home;
    target = home;
    path.clear();
    state = State::idle;
    item = false;
	delivered = false;
}

Position OrderPicker::getPosition() {
    return current;
}

std::vector<Position> OrderPicker::getPath() {
}

State OrderPicker::getState() {
    return state;
}

bool OrderPicker::hasItem() {
	return item;
}

bool OrderPicker::processItem(Position bin) {
    if ((state == State::idle) || (state == State::home) || ((state == State::yield) && (item == false))) {
        target = getFacingPosition(bin);
        state = State::retrieve;
        return true;
    }
    return false;
}

void OrderPicker::update(char map[10][10]) {
	switch (state) {
		case State::yield:
			if (delivered) {
				state = State::home;
			} else if (item) {
				state = State::ship;
			} else {
				state = State::retrieve;
			}
			break;
		case State::home:
			if (current != home) {
				path = findPath(current, home, map);
				if (path.empty()) state = State::yield;
				else {
					current = path.back();
					map[current.row][current.column] = 'X';
				}
				break;
			}
			if (delivered) {
				delivered = false;
				state = State::idle;
			} else if (item) {
				state = State::ship;
			} else {
				state = State::retrieve;
			}
			break;
		case State::retrieve:
			if (current != target) {
				path = findPath(current, target, map);
				if (path.empty()) state = State::yield;
				else {
					current = path.back();
					map[current.row][current.column] = 'X';
				}
				break;
			}
			state = State::extend;
			break;
		case State::ship:
			Position bin;
			bin.row = 9;
			bin.column = 1;
			bin.facing = up;
			bin = getFacingPosition(bin);
			if (current != bin) {
				path = findPath(current, bin, map);
				if (path.empty()) state = State::yield;
				else {
					current = path.back();
					map[current.row][current.column] = 'X';
				}
				break;
			}
			state = State::extend;
			break;
		case State::extend:
			if (item) state = State::place;
			else state = State::pick;
			break;
		case State::retract:
			if (item) {
				state = State::ship;
			} else {
				delivered = true;
				state = State::home;
			}
			break;
		case State::pick:
			item = true;
			state = State::retract;
			break;
		case State::place:
			item = false;
			delivered = true;
			state = State::retract;
			break;
    }
}

OrderPicker::~OrderPicker() {
    // nothing for now
}

struct PathNode {
    Position position;
    float F, G, H;
    PathNode* parent;
};

static std::vector<Position> getValidMoves(Position current, char map[10][10]) {
    std::vector<Position> moves;
    Position temp;
    
    // start by adding valid rotations
    temp.row = current.row;
    temp.column = current.column;
    switch (current.facing) {
        case up: case down:
            temp.facing = left;
            moves.push_back(temp);
            temp.facing = right;
            moves.push_back(temp);
            break;
        case left: case right:
            temp.facing = up;
            moves.push_back(temp);
            temp.facing = down;
            moves.push_back(temp);
            break;
    }

    // add moving forward, if valid
    temp.facing = current.facing;
    switch (current.facing) {
        case up:
            temp.row -= 1;
            break;
        case down:
            temp.row += 1;
            break;
        case left:
            temp.column -= 1;
            break;
        case right:
            temp.column += 1;
            break;
    }
    if ((temp.row >= 0) && (temp.row <= 9)) {
        if ((temp.column >= 0) && (temp.column <= 9)) {
            if (map[temp.row][temp.column] == '.') {
                moves.push_back(temp);
            }
        }
    }

    return moves;
}

static float getHeuristicDistance(Position current, Position destination) {
    // will use simple manhattan distance, ignoring rotations too
    return float(abs(destination.row-current.row) + abs(destination.column-current.column));
}

static std::vector<Position> findPath(Position start, Position end, char map[10][10]) {
    std::list<PathNode> openList, closedList;
    std::vector<Position> path;
    PathNode temp;
    Position temp_pos;
    
    // add starting node to open list
    temp.position.row = start.row;
    temp.position.column = start.column;
    temp.position.facing = start.facing;
    temp.parent = NULL;
    temp.G = 0.0;
    temp.H = getHeuristicDistance(start, end);
    temp.F = temp.G + temp.H;
    openList.push_back(temp);

    while (true) {
        // get current square and move to closed list
        PathNode current;
        std::list<PathNode>::iterator current_it = openList.begin();
        current = *current_it;
        for (std::list<PathNode>::iterator it = openList.begin(); it != openList.end(); it++) {
            if ((*current_it).F > (*it).F) {
                current_it = it;
                current = *it;
            }
        }
        closedList.push_back(current);
        openList.erase(current_it);

        // stop if the end node was just placed on the closed list (i.e. path found)
        if (current.position == end) {
			// Save the found path to the path vector. Start with the target square, going
			// through the parents until start node is reached.
			temp = closedList.back();
        	while (temp.parent != NULL) {
		        temp_pos = temp.position;
		        path.push_back(temp_pos);
		        temp = *(temp.parent);
		    }
			// Go return our populated path.
			break;
		}

        // for each valid move from current position...
        std::vector<Position> moves = getValidMoves(current.position, map);
        bool onClosedList, onOpenList;
        for (std::vector<Position>::iterator it = moves.begin(); it != moves.end(); it++) {
            // check if the move is not on the closed list
            onClosedList = false;
            for (std::list<PathNode>::iterator closed_it = closedList.begin(); closed_it != closedList.end(); closed_it++) {
                if ((*closed_it).position == (*it)) {
                    onClosedList = true;
                    break;
                }
            }
            if (!onClosedList) {
                // now check if the move is on the open list
                std::list<PathNode>::iterator found_it;
                onOpenList = false;
                for (std::list<PathNode>::iterator open_it = openList.begin(); open_it != openList.end(); open_it++) {
                    if ((*open_it).position == (*it)) {
                        found_it = open_it;
                        onOpenList = true;
                        break;
                    }
                }
                temp.position.row = (*it).row;
                temp.position.column = (*it).column;
                temp.position.facing = (*it).facing;
                // Be careful here. Remember the scope of the "current" variable. What we really want is the address
                // of the persistent PathNode representing current, which is stored at the end of closedList right now.
                temp.parent = &(closedList.back());
                temp.G = current.G + 1.0;
                temp.H = getHeuristicDistance(temp.position, end);
                temp.F = temp.G + temp.H;
                if (!onOpenList) {
                    // add move to open list, making current node the parent
                    openList.push_back(temp);
                } else {
                    // check if path to this position is better than the path
                    // used to get to this position, as stored on the open list.
                    // Replace if better.
                    if ((*found_it).G > temp.G) {
                        openList.erase(found_it);
                        openList.push_back(temp);
                    }
                }
            }
        }

        // Ff the open list is empty, and we are here, then there were no new nodes
        // to try and no path to destination was found (return empty path)
        if (openList.empty()) break;

    }

    return path;
}