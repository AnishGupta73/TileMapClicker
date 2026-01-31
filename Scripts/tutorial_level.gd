extends "res://Scripts/main_level.gd"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_grid = main_grid_inst.instantiate()
	add_child(main_grid)
	main_grid.n = main_grid_size
	main_grid.generate_grid_simple(main_grid_size, main_grid.grid_background_tile)
	main_grid.position = Vector2(16*(main_grid_location - Vector2i(main_grid_size/2, main_grid_size/2)))
	main_grid.has_won.connect(_on_has_won)
	
	main_tile_map = $MainTileMap
	
	$Control/LevelIndicator.text = "Tutorial 1"
	
	#Just the top one
	top_row = click_struct_inst.instantiate()
	add_child(top_row)
	top_row.generate_Struct(main_grid_size, 0, Vector2i(1, 0), Vector2i(0, 1))
	top_row.position = main_grid.position + 16*Vector2(0, -1)
	top_row.triggered_click.connect(_on_triggered_click)
	
	set_up_pieces()
	set_up_board()
	update_pieces_on_board()
	
	get_next_pieces_queue()
	distribute_queue_starting()


func set_up_board():
	var n = main_grid_size
	main_grid.set_board_cell(Vector2i(n/2-1, n/2+1), current_pieces[current_pieces.keys()[0]])
	main_grid.set_board_cell(Vector2i(n/2+1, n/2+1), current_pieces[current_pieces.keys()[1]])


func get_next_pieces_queue():
	next_piece_queue = ["A", "B", "A", "B"]


func distribute_queue_starting():
	var n = main_grid_size
	
	var piece_to_assign = next_piece_queue.pop_front()
	top_row.update_cells_tile_image(current_pieces[piece_to_assign])
	top_row.cell_entered(top_row.click_cell_array[n / 2])
	
	piece_to_assign = next_piece_queue.pop_front()
	main_tile_map.set_cell(next_piece_indicator_location, 0, current_pieces[piece_to_assign])
