extends Control

@export var start_scene: PackedScene
@export var tutorial_scene: PackedScene


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_scene)


func _on_tutorial_button_pressed() -> void:
	get_tree().change_scene_to_packed(tutorial_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
