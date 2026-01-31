extends Node2D

var grid:TileMapLayer

var num_next_pieces: int = 3

func _ready() -> void:
	grid = $Grid
	generate_grid_simple(Vector2i(5, 0), Vector2i(6, 0))

func generate_grid_simple(piece_tile:Vector2i, surround_tile_top_left:Vector2i):
	#Top layer is looped
	for i in range(3):
		grid.set_cell(Vector2i(i, 0), 0, surround_tile_top_left + Vector2i(i, 0))
	
	for i in range(num_next_pieces):
		grid.set_cell(Vector2i(0, 1+i), 0, surround_tile_top_left + Vector2i(0, 1))
		
		#special middle
		grid.set_cell(Vector2i(1, 1+i), 0, piece_tile)
		
		grid.set_cell(Vector2i(2, 1+i), 0, surround_tile_top_left + Vector2i(2, 1))
		
	for i in range(3):
		grid.set_cell(Vector2i(i, num_next_pieces+1), 0, surround_tile_top_left + Vector2i(i, 2))
		

#gets the bottom most piece in the queue
func get_next_piece():
	pass

#shifts the current pieces down by 1
func shift():
	pass
