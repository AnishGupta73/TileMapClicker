extends Node2D

@export var grid_size: int
@export var middle_tile: Vector2i
@export var outer_ring_scene: PackedScene
var top_row = []
var bot_row = []
var left_col = []
var right_col = []
var grid: TileMapLayer

var grid_background_tile:Vector2i = Vector2i(6, 5)

func _ready() -> void:
	grid = $Grid
	generate_grid_simple(grid_size, middle_tile)
	generate_outer_ring(grid_size)

func generate_grid_simple(n:int, tile:Vector2i):
	var m = n % 2
	for i in range(-n/2, n/2+m):
		for j in range(-n/2, n/2+m):
			grid.set_cell(Vector2i(i, j), 0, tile)

func generate_grid_clean(n:int):
	var adjustment:Vector2i = Vector2i(0, 0)
	for i in range(n):
		for j in range(n):
			if (j == 0):
				if (i == 0):
					adjustment = Vector2i(-1,-1)
				elif (i == n-1):
					adjustment = Vector2i(1,-1)
				else:
					adjustment = Vector2i(0,-1)
			elif (j == n-1):
				if (i == 0):
					adjustment = Vector2i(-1,1)
				elif (i == n-1):
					adjustment = Vector2i(1,1)
				else:
					adjustment = Vector2i(0,1)
			else:
				if (i == 0):
					adjustment = Vector2i(-1,0)
				elif (i == n-1):
					adjustment = Vector2i(1,0)
				else:
					adjustment = Vector2i(0,0)
			
			# offset by 1 to account for the outer ring
			grid.set_cell(Vector2i(i+1, j+1), 0, middle_tile + adjustment)

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
	var group_type = source.group
	if (group_type == 0):
		pass
	elif (group_type == 1):
		pass
	elif (group_type == 2):
		pass
	elif (group_type == 3):
		pass
