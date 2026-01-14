extends Node2D

@export var grid_size: int
@export var outer_ring_scene: PackedScene
var top_row = []
var bot_row = []
var left_col = []
var right_col = []
var grid: TileMapLayer

var grid_background_tile:Vector2i = Vector2i(5, 0)

signal has_won



func _ready() -> void:
	grid = $Grid
	#generate_grid_simple(grid_size, grid_background_tile)
	#set_up_board()




func generate_grid_simple(n:int, tile:Vector2i):
	for i in range(0, n):
		for j in range(0, n):
			grid.set_cell(Vector2i(i, j), 0, tile)





func get_grid_cell(location:Vector2i):
	return grid.get_cell_atlas_coords(location)


func set_grid_cell(grid_location:Vector2i, new_image:Vector2i):
	if (grid_location[0] >= grid_size or grid_location[1] >= grid_size):
		return
	grid.set_cell(grid_location, 0, new_image)


func dropped_image(index:Vector2i, direction:Vector2i, image_dropped: Vector2i):
	var current_cell_location = index + direction
	
	# Lose the game if u drop in a line that cant take more
	if (get_grid_cell(current_cell_location) != grid_background_tile):
		return Vector2i(-1, -1)
	
	while (current_cell_location[0] < grid_size and current_cell_location[1] < grid_size):
		var cell = get_grid_cell(current_cell_location)
		if (cell != grid_background_tile):
			#collision so break as we have found the cell location
			break
		current_cell_location += direction
	
	set_grid_cell(current_cell_location - direction, image_dropped)
	return current_cell_location - direction
	

func clean_consecutives(start_location:Vector2i):
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
	
	
	if (potential_to_remove.size() >= 3):
		await get_tree().create_timer(0.5).timeout
		for item in potential_to_remove:
			set_grid_cell(item, grid_background_tile)
		check_win()

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
		if (get_grid_cell(cell_location) == get_grid_cell(start_location)):
			toReturn.append(cell_location)
	
	return toReturn

func check_win():
	for i in range(0, grid_size):
		for j in range(0, grid_size):
			if (get_grid_cell(Vector2i(i, j)) != grid_background_tile):
				return
	has_won.emit()
