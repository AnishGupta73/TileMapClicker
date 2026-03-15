extends Control

@export var level_number : String = "0"
@export var level_to_load : PackedScene

var button : Button

func _on_ready() -> void:
	button = $Button
	button.text = level_number


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(level_to_load)
	
