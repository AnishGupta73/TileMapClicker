extends Node2D


# Main Grid vars
@export var main_grid_size: int = 9
@export var main_grid_location = Vector2i(13, 7)
var main_grid_inst : PackedScene = preload("res://Scenes/main_grid.tscn")
var main_grid


# Piece Indicator vars
var piece_grid_inst : PackedScene = preload("res://Scenes/piece_grid.tscn")
var piece_grid
@export var piece_inclusion = {
	"A": true,
	"B": true,
	"C": true,
	"D": true,
	"E": true,
}
@export var num_next_pieces_indicator: int = 1

var current_pieces = {}
var main_tile_map: Node2D
var piece_image_map = {
	"A": Vector2i(0, 1),
	"B": Vector2i(1, 1),
	"C": Vector2i(2, 1),
	"D": Vector2i(3, 1),
	"E": Vector2i(4, 1),
}
var pieces_count = {}
var next_piece_queue: Array
@export var next_piece_indicator_location: Vector2i = Vector2i(4, 7)


# Click Struct vars
var click_struct_inst : PackedScene = preload("res://Scenes/click_struct.tscn")
var top_row
var bot_row
var left_col
var right_col


# Other vars
@export var scene_to_change_upon_win: String
var level_number = 1

func _ready() -> void:
	# Generate the main grid
	main_grid = main_grid_inst.instantiate()
	add_child(main_grid)
	main_grid.n = main_grid_size
	main_grid.generate_grid_simple(main_grid_size, main_grid.grid_background_tile)
	main_grid.position = Vector2(16*(main_grid_location - Vector2i(main_grid_size/2, main_grid_size/2)))
	main_grid.has_won.connect(_on_has_won)
	
	main_tile_map = $MainTileMap
	
	$Control/LevelIndicator.text = "Level " + str(level_number)
	
	# Generate the 4 Click Structs around the grid
	top_row = click_struct_inst.instantiate()
	add_child(top_row)
	top_row.generate_Struct(main_grid_size, 0, Vector2i(1, 0), Vector2i(0, 1))
	top_row.position = main_grid.position + 16*Vector2(0, -1)
	top_row.triggered_click.connect(_on_triggered_click)
	
	bot_row = click_struct_inst.instantiate()
	add_child(bot_row)
	bot_row.generate_Struct(main_grid_size, 1, Vector2i(1, 0), Vector2i(0, -1))
	bot_row.position = main_grid.position + 16*Vector2(0, main_grid_size)
	bot_row.triggered_click.connect(_on_triggered_click)
	
	left_col = click_struct_inst.instantiate()
	add_child(left_col)
	left_col.generate_Struct(main_grid_size, 2, Vector2i(0, 1), Vector2i(1, 0))
	left_col.position = main_grid.position + 16*Vector2(-1, 0)
	left_col.triggered_click.connect(_on_triggered_click)
	
	right_col = click_struct_inst.instantiate()
	add_child(right_col)
	right_col.generate_Struct(main_grid_size, 3, Vector2i(0, 1), Vector2i(-1, 0))
	right_col.position = main_grid.position + 16*Vector2(main_grid_size, 0)
	right_col.triggered_click.connect(_on_triggered_click)
	
	# Set up first pieces, then the board, then counts them properly
	set_up_pieces()
	set_up_board()
	update_pieces_on_board()
	
	get_next_pieces_queue()
	distribute_queue_starting()

func set_up_pieces():
	#piece_grid = piece_grid_inst.instantiate()
	#piece_grid.num_next_pieces = num_next_pieces_indicator
	#add_child(piece_grid)
	
	for key in piece_inclusion.keys():
		if piece_inclusion[key]:
			current_pieces[key] = piece_image_map[key]
			pieces_count[key] = 0



func set_up_board():
	var n = main_grid_size
	main_grid.set_board_cell(Vector2i(n/2, n/2), current_pieces[current_pieces.keys()[0]])
	#main_grid.set_board_cell(Vector2i(n/2+1, n/2), current_pieces["B"])
	#main_grid.set_board_cell(Vector2i(n/2, n/2+1), current_pieces["C"])
	#main_grid.set_board_cell(Vector2i(n/2-1, n/2), current_pieces["D"])
	#main_grid.set_board_cell(Vector2i(n/2, n/2-1), current_pieces["E"])


func _on_has_won():
	print("empty board")
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scene_to_change_upon_win)


func set_input(val:bool):
	top_row.set_clickability(val)
	bot_row.set_clickability(val)
	left_col.set_clickability(val)
	right_col.set_clickability(val)

func _on_triggered_click(group:int, source_idx:int, drop_direction:Vector2i, image:Vector2i):
	var location_dropped_at: Vector2i
	
	match group:
		0:
			location_dropped_at = main_grid.dropped_image(Vector2i(source_idx, -1), drop_direction, image)
			distribute_next(top_row, source_idx)
		1: 
			location_dropped_at = main_grid.dropped_image(Vector2i(source_idx, main_grid_size), drop_direction, image)
			distribute_next(bot_row, source_idx)
		2: 
			location_dropped_at = main_grid.dropped_image(Vector2i(-1, source_idx), drop_direction, image)
			distribute_next(left_col, source_idx)
		3:
			location_dropped_at = main_grid.dropped_image(Vector2i(main_grid_size, source_idx), drop_direction, image)
			distribute_next(right_col, source_idx)
	
	if location_dropped_at == Vector2i(-1, -1):
		set_input(false)
		print("Lose Game")
		await get_tree().create_timer(0.5).timeout
		set_input(true)
		get_tree().quit()
	
	#after dropping image need to check if we have 3 of the same cell adjacent
	var potential_to_remove =  main_grid.get_consecutives_to_clean(location_dropped_at)
	if (potential_to_remove.size() >= 3):
		#set_input(false)
		await get_tree().create_timer(0.5).timeout
		for item in potential_to_remove:
			main_grid.board.set_cell(item, -1) # clears the cell
		main_grid.check_win()
		#set_input(true)
	update_pieces_on_board()


func update_pieces_on_board():
	var n = main_grid_size
	var keys = current_pieces.keys()
	var vals = current_pieces.values()
	
	#reset the count of all the current pieces
	for key in keys:
		pieces_count[key] = 0
	
	for i in range(0, n):
		for j in range(0, n):
			#get the cell
			var cell = main_grid.get_board_cell(Vector2i(i, j))
			
			#check if the cell is empty
			if cell != Vector2i(-1, -1):
				# find which key the cell is (by searching which val it is)
				# and then add 1 to that key in pieces_count
				pieces_count[keys[vals.find(cell)]] += 1


func get_next_pieces_queue():
	var next_pieces_unshuffled = []
	# for each key, find its val, engineer its count, and add that many into an array
	var keys = current_pieces.keys()
	for key in keys:
		var val = pieces_count[key]
		var count_to_add = 6 - (val%3)
		for i in range(count_to_add):
			next_pieces_unshuffled.append(key)
	
	next_pieces_unshuffled.shuffle()
	next_piece_queue = next_pieces_unshuffled

func distribute_queue_starting():
	var n = main_grid_size
	
	var piece_to_assign = next_piece_queue.pop_front()
	top_row.update_cells_tile_image(current_pieces[piece_to_assign])
	top_row.cell_entered(top_row.click_cell_array[n / 2])
	
	piece_to_assign = next_piece_queue.pop_front()
	bot_row.update_cells_tile_image(current_pieces[piece_to_assign])
	bot_row.cell_entered(bot_row.click_cell_array[n / 2])
	
	piece_to_assign = next_piece_queue.pop_front()
	left_col.update_cells_tile_image(current_pieces[piece_to_assign])
	left_col.cell_entered(left_col.click_cell_array[n / 2])
	
	piece_to_assign = next_piece_queue.pop_front()
	right_col.update_cells_tile_image(current_pieces[piece_to_assign])
	right_col.cell_entered(right_col.click_cell_array[n / 2])
	
	
	piece_to_assign = next_piece_queue.pop_front()
	main_tile_map.set_cell(next_piece_indicator_location, 0, current_pieces[piece_to_assign])
	
func distribute_next(next_click_struct, source_idx):
	var piece_to_assign_struct = main_tile_map.get_cell_atlas_coords(next_piece_indicator_location)
	var vals = current_pieces.values()
	var keys = current_pieces.keys()
	
	next_click_struct.update_cells_tile_image(current_pieces[keys[vals.find(piece_to_assign_struct)]])
	#next_click_struct.cell_entered(next_click_struct.click_cell_array[source_idx]) -> should happen after disappearing timer in triggered click
	
	if next_piece_queue.size() <= 0:
		get_next_pieces_queue()
	
	var piece_to_assign = next_piece_queue.pop_front()
	main_tile_map.set_cell(next_piece_indicator_location, 0, current_pieces[piece_to_assign])
