extends "res://Scripts/main_level.gd"


var script_part: int = 0
var text_boxes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	#main_grid = main_grid_inst.instantiate()
	#add_child(main_grid)
	#main_grid.n = main_grid_size
	#main_grid.generate_grid_simple(main_grid_size, main_grid.grid_background_tile)
	#main_grid.position = Vector2(16*(main_grid_location - Vector2i(main_grid_size/2, main_grid_size/2)))
	#main_grid.has_won.connect(_on_has_won)
	#
	#main_tile_map = $MainTileMap
	text_boxes = [$Control/HoverAndDropText, $Control/NextPieceText, $Control/GoalText]
	
	$Control/LevelIndicator.text = "Tutorial 1"
	
	##Just the top one
	#set_up_click_structs()
	#
	#set_up_pieces()
	#set_up_board()
	#update_pieces_count_on_board()
	#
	#get_next_pieces_queue()
	#distribute_queue_starting()
	#
	script_set_up()


func script_set_up():
	script_part = 0
	text_boxes[1].visible = false
	text_boxes[2].visible = false
	$Up.visible = false

func next_script():
	text_boxes[script_part % text_boxes.size()].visible = false
	script_part += 1
	text_boxes[script_part % text_boxes.size()].visible = true
	
func _on_triggered_click(source_struct : ClickStruct, source_idx:int, drop_direction:Vector2i, image:Vector2i):
	super(source_struct, source_idx, drop_direction, image)
	
	if (script_part == 0):
		$Down.visible = false
		$Down2.visible = false
		$Down3.visible = false
		
		$Up.visible = true
	elif (script_part == 1):
		$Up.visible = false
	
	script_part += 1
	if (script_part <= 2):
		text_boxes[script_part].visible = true
	
