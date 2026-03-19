extends Control

var menu_button : Button
var level_button : Button
var next_button : Button
var next_level_file : String

func _on_ready() -> void:
	menu_button = $HBoxContainer/MainMenu
	level_button = $HBoxContainer/LevelSelect
	next_button = $HBoxContainer/NextLevel


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	queue_free()


func _on_level_select_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/level_select.tscn")
	queue_free()


func _on_next_level_pressed() -> void:
	get_tree().change_scene_to_file(next_level_file)
	queue_free()
