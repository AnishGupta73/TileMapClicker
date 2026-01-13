extends Node2D

@export var grid_size: int
@export var outer_ring_scene: PackedScene
var top_row = []
var bot_row = []
var left_col = []
var right_col = []
var grid: TileMapLayer

var grid_background_tile:Vector2i = Vector2i(6, 5)

var pieces = {
	"A": Vector2i(16, 0),
	"B": Vector2i(15, 0),
	"C": Vector2i(14, 0),
	"D": Vector2i(13, 0),
	"E": Vector2i(15, 1),
}


func _ready() -> void:
	grid = $Grid
	generate_grid_simple(grid_size, grid_background_tile)
	generate_outer_ring(grid_size)
	set_up_board()


func set_up_board():
	grid.set_cell(Vector2i(0, 0), 0, pieces["A"])


func generate_grid_simple(n:int, tile:Vector2i):
	var m = n % 2
	for i in range(-n/2, n/2+m):
		for j in range(-n/2, n/2+m):
			grid.set_cell(Vector2i(i, j), 0, tile)


func generate_outer_ring(n:int):
	var instance
	var m = n % 2
	for i in range(-n/2, n/2+m):
		#top row
		instance = grab_instance()
		instance.position = 16*Vector2(i, -n/2-1)
		instance.group = 0
		top_row.append(instance)
		
		#bot row
		instance = grab_instance()
		instance.position = 16*Vector2(i, n/2+m)
		instance.group = 1
		bot_row.append(instance)
		
		#left col
		instance = grab_instance()
		instance.position = 16*Vector2(-n/2-1, i)
		instance.group = 2
		left_col.append(instance)
		
		#right col
		instance = grab_instance()
		instance.position = 16*Vector2(n/2+m, i)
		instance.group = 3
		right_col.append(instance)
	
	top_row[n/2].set_image(top_row[n/2].new_image_coords)
	bot_row[n/2].set_image(bot_row[n/2].new_image_coords)
	left_col[n/2].set_image(left_col[n/2].new_image_coords)
	right_col[n/2].set_image(right_col[n/2].new_image_coords)

func grab_instance():
	var instance = outer_ring_scene.instantiate()
	grid.add_child(instance)
	instance.mouse_entered_cell.connect(cell_entered)
	instance.mouse_clicked_cell.connect(cell_clicked)
	return instance

func cell_entered(source:Node):
	var group_type = source.group
	if (group_type == 0):
		for cell in top_row:
			if (cell == source):
				cell.set_image(cell.new_image_coords)
			else:
				cell.set_image(cell.old_image_coords)
	elif (group_type == 1):
		for cell in bot_row:
			if (cell == source):
				cell.set_image(cell.new_image_coords)
			else:
				cell.set_image(cell.old_image_coords)
	elif (group_type == 2):
		for cell in left_col:
			if (cell == source):
				cell.set_image(cell.new_image_coords)
			else:
				cell.set_image(cell.old_image_coords)
	elif (group_type == 3):
		for cell in right_col:
			if (cell == source):
				cell.set_image(cell.new_image_coords)
			else:
				cell.set_image(cell.old_image_coords)

func cell_clicked(source:Node):
	var current_group = [top_row, bot_row, left_col, right_col][source.group]
	var index_in_group = current_group.find(source)
	
	#top & bottom row
	if source.group <= 1:
		var index_to_past_to = get_index_after_collision(current_group, index_in_group)
		set_grid_cell(Vector2i(index_in_group, index_to_past_to), source.new_image_coords)
		
		#clean_3_in_a_row(Vector2i(index_in_group, index_to_past_to), source.new_image_coords)
	
	# left and right col
	else: 
		var index_to_past_to = get_index_after_collision(current_group, index_in_group)
		set_grid_cell(Vector2i(index_to_past_to, index_in_group), source.new_image_coords)
		
	
	
	
	
	
	
	# set the clicked on cell's new image to the new icon
	var rand_next = pieces.keys().pick_random()
	for cell in current_group:
		cell.new_image_coords = pieces[rand_next]
	# refresh clicked on cell to new one
	cell_entered(source)


func get_grid_cell(location:Vector2i):
	return grid.get_cell_atlas_coords(Vector2i(location[0] - grid_size/2, location[1] - grid_size/2))


func set_grid_cell(grid_location:Vector2i, new_image:Vector2i):
	if (grid_location[0] >= grid_size or grid_location[1] >= grid_size):
		return
	grid.set_cell(Vector2i(grid_location[0] - grid_size/2, grid_location[1] - grid_size/2), 0, new_image)


func get_index_after_collision(group: Array, fixed_idx: int):
	# Depending on the group, look down, up, right or left
	var gr_idx = [top_row, bot_row, left_col, right_col].find(group)
	var dir_delta:Vector2i 
	match gr_idx:
		0: # top
			# Keep updating until collision or end of grid
			for i in range(grid_size):
				var curr_cell_coords = (Vector2i(fixed_idx - grid_size/2, i - grid_size/2))
				if grid.get_cell_atlas_coords(curr_cell_coords) != grid_background_tile:
					#Collision
					return i-1
			return grid_size - 1
		1: # bottom
			for i in range(grid_size - 1, -1, -1):
				var curr_cell_coords = (Vector2i(fixed_idx - grid_size/2, i - grid_size/2))
				if grid.get_cell_atlas_coords(curr_cell_coords) != grid_background_tile:
					#Collision
					return i+1
			return 0
		2: # left
			for i in range(grid_size):
				var curr_cell_coords = (Vector2i(i - grid_size/2, fixed_idx - grid_size/2))
				if grid.get_cell_atlas_coords(curr_cell_coords) != grid_background_tile:
					#Collision
					return i-1
			return grid_size - 1
		3: # right
			for i in range(grid_size-1, -1, -1):
				var curr_cell_coords = (Vector2i(i - grid_size/2, fixed_idx - grid_size/2))
				if grid.get_cell_atlas_coords(curr_cell_coords) != grid_background_tile:
					#Collision
					return i+1
			return 0
	

func clean_3_in_a_row(start_location:Vector2i, image_to_check:Vector2i):
	# Check for 3 in a row and only need to check for the image of the placed piece and
	# its immediate neighbors.
	# assume we have found one until proven otherwise
	var potential_to_remove = [start_location]
	
	var adjacent = [
		Vector2i(start_location[0]+1, start_location[1]), 
		Vector2i(start_location[0], start_location[1]+1), 
		Vector2i(start_location[0]-1, start_location[1]), 
		Vector2i(start_location[0], start_location[1]-1)
	]
	
	for cell in adjacent:
		if ((grid.get_cell_atlas_coords(cell) == image_to_check) and (potential_to_remove.find(cell) == -1)):
			potential_to_remove.insert(0, cell)
			var adjacent2 = [
				Vector2i(cell[0]+1, cell[1]), 
				Vector2i(cell[0], cell[1]+1), 
				Vector2i(cell[0]-1, cell[1]), 
				Vector2i(cell[0], cell[1]-1)
			]
			for cell2 in adjacent2:
				if ((grid.get_cell_atlas_coords(cell2) == image_to_check) and (potential_to_remove.find(cell2) == -1)):
					potential_to_remove.insert(0, cell2)
					break
		else:
			continue
			
	print(potential_to_remove)
	if (potential_to_remove.size() >= 3):
		print("Need to remove")
		for cell_to_remove in potential_to_remove:
			grid.set_cell(cell_to_remove, 0, grid_background_tile)
		
