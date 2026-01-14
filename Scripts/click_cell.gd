extends Node2D

var button: Button
var image: TileMapLayer

signal mouse_entered_cell(source: Node)
signal mouse_clicked_cell(source: Node)

signal test


func _ready() -> void:
	button = $Button
	image = $Image


func get_image():
	image.get_cell_atlas_coords(Vector2i(0, 0))

func set_image(coords:Vector2i):
	image.set_cell(Vector2i(0, 0), 0, coords)


func _on_button_mouse_entered() -> void:
	mouse_entered_cell.emit(self)


func _on_button_mouse_exited() -> void:
	pass


func _on_button_pressed() -> void:
	mouse_clicked_cell.emit(self)
