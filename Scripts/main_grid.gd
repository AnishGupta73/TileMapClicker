extends Node2D

var n: int
var grid: TileMapLayer
var board: TileMapLayer

var grid_background_tile:Vector2i = Vector2i(5, 0)

signal has_won



func _ready() -> void:
	grid = $Grid
	board = $Board


func generate_grid_simple(n:int, tile:Vector2i):
	for i in range(0, n):
		for j in range(0, n):
			grid.set_cell(Vector2i(i, j), 0, tile)


func get_grid_cell(location:Vector2i):
	var id = grid.get_cell_source_id(location)
	if (id == -1):
		return Vector2i(-1, -1)
	return grid.get_cell_atlas_coords(location)
	
func get_board_cell(location:Vector2i):
	var id = board.get_cell_source_id(location)
	if (id == -1):
		return Vector2i(-1, -1)
	return board.get_cell_atlas_coords(location)


func set_board_cell(grid_location:Vector2i, new_image:Vector2i):
	if (grid_location[0] >= n or grid_location[1] >= n):
		return
	board.set_cell(grid_location, 0, new_image)


func dropped_image(index:Vector2i, direction:Vector2i, image_dropped: Vector2i):
	var current_cell_location = index + direction
	
	# Lose the game if u drop in a line that cant take more
	if (get_board_cell(current_cell_location) != Vector2i(-1, -1)):
		return Vector2i(-1, -1)
		
	
	for i in range(n):
		var cell = get_board_cell(current_cell_location)
		if (cell != Vector2i(-1, -1)):
			#collision so break as we have found the cell location
			break
		current_cell_location += direction
	
	#set the last cell in the row or col if it is empty.
	set_board_cell(current_cell_location - direction, image_dropped)
	return current_cell_location - direction
	

func get_consecutives_to_clean(start_location:Vector2i):
	# Check for 3 in a row and only need to check for the image of the placed piece and
	# its immediate neighbors.
	# assume we have found one until proven otherwise
	var potential_to_remove = [start_location]
	
	var adjacents = find_adjacent(start_location)
	for i in adjacents:
		potential_to_remove.append(i)
	
	for cell_location in adjacents:
		var to_add = find_adjacent(cell_location)
		for thing in to_add:
			if (potential_to_remove.find(thing) == -1):
				potential_to_remove.append(thing)
	
	return potential_to_remove

## returns a list of cells that are adjacent to start location that have the same image as start_location
func find_adjacent(start_location:Vector2i):
	var toReturn = []
	var adjacent = [
		Vector2i(start_location[0]+1, start_location[1]), 
		Vector2i(start_location[0], start_location[1]+1), 
		Vector2i(start_location[0]-1, start_location[1]), 
		Vector2i(start_location[0], start_location[1]-1)
	]
	for cell_location in adjacent:
		if (get_board_cell(cell_location) == get_board_cell(start_location)):
			toReturn.append(cell_location)
	
	return toReturn

func check_win():
	for i in range(0, n):
		for j in range(0, n):
			if (get_board_cell(Vector2i(i, j)) != Vector2i(-1, -1)):
				return
	has_won.emit()
