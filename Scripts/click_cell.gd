extends Node2D

var button: Button
var background_image: TileMapLayer
var tile_image: TileMapLayer

var can_click: bool

signal mouse_entered_cell(source: Node)
signal mouse_exited_cell(source: Node)
signal mouse_clicked_cell(source: Node)


func _ready() -> void:
	button = $Button
	background_image = $BackgroundImage
	tile_image = $TileImage
	
	set_background_image(Vector2i(5, 0))
	set_clickability(true)


func get_background_image():
	background_image.get_cell_atlas_coords(Vector2i(0, 0))

func set_background_image(coords:Vector2i):
	background_image.set_cell(Vector2i(0, 0), 0, coords)

func get_tile_image():
	background_image.get_cell_atlas_coords(Vector2i(0, 0))
	
func set_tile_image(coords:Vector2i):
	tile_image.set_cell(Vector2i(0, 0), 0, coords)


func set_tile_visibility(val:bool):
	tile_image.visible = val

func set_clickability(val:bool):
	can_click = val
	#button.visible = val

func _on_button_mouse_entered() -> void:
	if (can_click):
		mouse_entered_cell.emit(self)


func _on_button_mouse_exited() -> void:
	if (can_click):
		mouse_exited_cell.emit(self)


func _on_button_pressed() -> void:
	if (can_click):
		mouse_clicked_cell.emit(self)
