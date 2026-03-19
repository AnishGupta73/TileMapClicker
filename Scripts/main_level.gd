extends Node2D


@export var level_number = 0

# Main Grid vars
@export var main_grid_size: Vector2i = Vector2i(0, 0)

@export var main_grid_center = Vector2i(13, 7)
var main_grid_inst : PackedScene = preload("res://Scenes/main_grid.tscn")
var main_grid

# labels are:  group + "_" + length
@export var click_structs_label : Array[String] = ["N_9", "E_9", "S_9", "W_9"]

@export var click_structs_locations : Array[Vector2i] = [Vector2i(9, 2), Vector2i(18, 3), Vector2i(9, 12), Vector2i(8, 3)]

@export var starting_piece_locations = {
	"A": [Vector2i(4, 4)],
	"B": [],
	"C": [],
	"D": [],
	"E": []
}

# Click Struct vars
var click_struct_inst : PackedScene = preload("res://Scenes/Clicks/click_struct.tscn")
var click_struct_array : Array

# Piece Indicator vars
var piece_grid_inst : PackedScene = preload("res://Scenes/piece_grid.tscn")

@export var piece_inclusion_map = {
	"A": true,
	"B": true,
	"C": true,
	"D": true,
	"E": true,
}

@export var starting_pieces_queue : Array[String]

@export var starting_piece_queue_looped : bool = false

@export var num_next_pieces_indicator: int = 1

var current_pieces = {}
var main_tile_map: Node2D
var piece_image_map = {
	"A": Vector2i(0, 0),
	"B": Vector2i(1, 0),
	"C": Vector2i(2, 0),
	"D": Vector2i(3, 0),
	"E": Vector2i(4, 0),
}

var pieces_count = {}
var next_piece_queue: Array
@export var next_piece_indicator_location: Vector2i = Vector2i(4, 7)


# Other vars
@export var scene_to_change_upon_win: String = "res://Scenes/main_menu.tscn"

var reset_sound : AudioStreamPlayer2D
var next_sound : AudioStreamPlayer2D


func _ready() -> void:
	main_tile_map = $MainTileMap
	
	$Control/LevelIndicator.text = "Level " + str(level_number)
	
	reset_sound = $ResetSound
	next_sound = $NextSound
	
	
	# Generate the main grid
	set_up_main_grid()
	
	# Generate the Click Structs around the grid
	set_up_click_structs()
	
	# Set up first pieces to be included, then the starting pieces on the board, then count them properly
	set_up_pieces()
	set_up_board()
	update_pieces_count_on_board()
	
	# Create the queue for the stream of next pieces, distribute them to the click structs
	get_next_pieces_queue()
	distribute_queue_starting()



func set_up_main_grid():
	main_grid = main_grid_inst.instantiate()
	add_child(main_grid)
	main_grid.generate_grid(main_grid_size[0], main_grid_size[1])
	main_grid.position = Vector2(16*(main_grid_center - Vector2i(main_grid_size[0]/2, main_grid_size[1]/2)))
	main_grid.grid_global_location = Vector2i(main_grid.position / 16)
	main_grid.has_won.connect(_on_has_won)



func set_up_click_structs():
	for i in range(click_structs_label.size()):
		var click_struct_name = click_structs_label[i]
		var click_struct_loc = click_structs_locations[i]
		var inst = click_struct_inst.instantiate()
		add_child(inst)
		
		var parts = click_struct_name.split("_")
		inst.generate_Struct(parts[0], int(parts[1]))
		inst.position = 16*click_struct_loc
		
		inst.triggered_click.connect(_on_triggered_click)
		
		click_struct_array.append(inst)


func set_up_pieces():	
	for key in piece_inclusion_map.keys():
		if piece_inclusion_map[key]:
			current_pieces[key] = piece_image_map[key]
			pieces_count[key] = 0



func set_up_board():
	for key in starting_piece_locations.keys():
		if (current_pieces.keys().has(key)):
			for loc in starting_piece_locations[key]:
				main_grid.set_board_cell(loc, current_pieces[key])



func update_pieces_count_on_board():
	var x_size = main_grid_size[0]
	var y_size = main_grid_size[1]
	var keys = current_pieces.keys()
	var vals = current_pieces.values()
	
	#reset the count of all the current pieces
	for key in keys:
		pieces_count[key] = 0
	
	for i in range(0, x_size):
		for j in range(0, y_size):
			#get the cell
			var cell = main_grid.get_board_cell(Vector2i(i, j))
			
			#check if the cell is empty
			if cell != Vector2i(-1, -1):
				# find which key the cell is (by searching which val it is)
				# and then add 1 to that key in pieces_count
				pieces_count[keys[vals.find(cell)]] += 1


var count : int = 0
func get_next_pieces_queue():
	var next_pieces_shuffled = []
	# for each key, find its val, engineer its count, and add that many into an array
	for key in current_pieces.keys():
		var val = pieces_count[key]
		var count_to_add = 6 - (val%3)
		for i in range(count_to_add):
			next_pieces_shuffled.append(key)
	next_pieces_shuffled.shuffle()
	
	
	if (starting_pieces_queue.is_empty()):
		next_piece_queue += next_pieces_shuffled
	else:
		if starting_piece_queue_looped:# looped and full: add starting only
			next_piece_queue += starting_pieces_queue
		else: # not looped and full: shuffle after once providing starting
			if (count == 0):
				next_piece_queue += starting_pieces_queue + next_pieces_shuffled
				count += 1
			else:
				next_piece_queue = next_pieces_shuffled



func distribute_queue_starting():
	var piece_to_assign
	if next_piece_queue.size() <= 0:
		get_next_pieces_queue()
		
	for click_struct in click_struct_array:
		piece_to_assign = next_piece_queue.pop_front()
		click_struct.update_cells_tile_image(current_pieces[piece_to_assign], piece_to_assign)
		click_struct.cell_entered(click_struct.click_cell_array[(click_struct.struct_size)/2])
	
	if next_piece_queue.size() <= 0:
		get_next_pieces_queue()
	
	piece_to_assign = next_piece_queue.pop_front()
	
	main_tile_map.set_cell(next_piece_indicator_location, 0, current_pieces[piece_to_assign])



func distribute_next(next_click_struct):
	var piece_to_assign_struct = main_tile_map.get_cell_atlas_coords(next_piece_indicator_location)
	var vals = current_pieces.values()
	var keys = current_pieces.keys()
	
	var piece_to_assign = keys[vals.find(piece_to_assign_struct)]
	next_click_struct.update_cells_tile_image(current_pieces[piece_to_assign], piece_to_assign)
	
	if next_piece_queue.size() <= 0:
		get_next_pieces_queue()
	
	piece_to_assign = next_piece_queue.pop_front()
	main_tile_map.set_cell(next_piece_indicator_location, 0, current_pieces[piece_to_assign])



func _on_has_won():
	next_sound.play(0.0)
	await get_tree().create_timer(0.5).timeout
	
	for c_s in click_struct_array:
		c_s.set_clickability(false)
		
	var pop_up_scene = load("res://Scenes/UI/pop_up.tscn")
	var pop_up_inst = pop_up_scene.instantiate()
	pop_up_inst.next_level_file = scene_to_change_upon_win
	get_parent().add_child(pop_up_inst)
	
	#get_tree().change_scene_to_file(scene_to_change_upon_win)



func _on_triggered_click(source_struct : ClickStruct, source_idx:int, drop_direction:Vector2i, image:Vector2i):
	var location_dropped_at = main_grid.dropped_image(Vector2i(source_struct.position / 16) + (source_idx * source_struct.growth_dir), drop_direction, image)
	
	distribute_next(source_struct)
	
	var trigger_reload = false
	if location_dropped_at == Vector2i(-1, -1):
		trigger_reload = true
		
	#after dropping image need to check if we have 3 of the same cell adjacent
	remove_adjacents(location_dropped_at)
	
	update_pieces_count_on_board()
	
	if (trigger_reload):
		reset_sound.play(0.0)
		await get_tree().create_timer(0.6).timeout
		get_tree().reload_current_scene()



func remove_adjacents(location_dropped_at: Vector2i):
	var potential_to_remove =  main_grid.get_consecutives_to_clean(location_dropped_at)
	if (potential_to_remove.size() >= 3):
		
		#timer so we can play some animations
		await get_tree().create_timer(0.5).timeout
		
		for item in potential_to_remove:
			main_grid.board.set_cell(item, -1) # clears the cell
		main_grid.check_win()



func set_input(val:bool):
	for c_s in click_struct_array:
		c_s.set_clickability(val)
