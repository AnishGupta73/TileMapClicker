extends Node2D

var button: Button
var image: TileMapLayer
var old_image_coords: Vector2i = Vector2i(5, 5)
var new_image_coords: Vector2i = Vector2i(16, 0)

signal mouse_entered_cell(source: Node)
signal mouse_clicked_cell(source: Node)

signal test

enum tile_group {
	TOP,
	BOTTOM,
	LEFT,
	RIGHT
}
var group: tile_group


func _ready() -> void:
	button = $Button
	image = $Image
	set_image(old_image_coords)

func get_current_image():
	image.get_cell_atlas_coords(Vector2i(0, 0))

func set_image(coords:Vector2i):
	image.set_cell(Vector2i(0, 0), 0, coords)

func _on_button_mouse_entered() -> void:
	set_image(new_image_coords)
	mouse_entered_cell.emit(self)


func _on_button_mouse_exited() -> void:
	pass


func _on_button_pressed() -> void:
	mouse_clicked_cell.emit(self)
