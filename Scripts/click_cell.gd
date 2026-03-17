extends Node2D
class_name ClickCell

var button: Button
var background_image: TileMapLayer
var tile_image: TileMapLayer
var animated_image: AnimatedSprite2D
var audio_player: AudioStreamPlayer2D

var can_click: bool

signal mouse_entered_cell(source: ClickCell)
signal mouse_exited_cell(source: ClickCell)
signal mouse_clicked_cell(source: ClickCell)


func _ready() -> void:
	button = $Button
	background_image = $BackgroundImage
	tile_image = $TileImage
	animated_image = $AnimatedImage
	audio_player = $AudioStreamPlayer2D
	
	set_background_image(Vector2i(1, 2))
	set_clickability(true)


func get_background_image():
	background_image.get_cell_atlas_coords(Vector2i(0, 0))

func set_background_image(coords:Vector2i):
	background_image.set_cell(Vector2i(0, 0), 0, coords)

func get_tile_image():
	background_image.get_cell_atlas_coords(Vector2i(0, 0))
	
func set_tile_image(coords:Vector2i, animation_name:String):
	tile_image.set_cell(Vector2i(0, 0), 0, coords)
	animated_image.play(animation_name)
	#print(animation_name)
	#print(animated_image.sprite_frames.get_animation_names())
	

func set_tile_visibility(val:bool):
	#tile_image.visible = val
	animated_image.visible = val

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
		audio_player.pitch_scale = 1.0 + RandomNumberGenerator.new().randf_range(-0.15, 0.15)
		audio_player.play(0.0)
