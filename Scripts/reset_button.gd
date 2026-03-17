extends Control

var main_animation : AnimatedSprite2D
var confirm_animation : AnimatedSprite2D
var cancel_animation : AnimatedSprite2D

var current_visibility : bool = false

func _on_ready() -> void:
	main_animation = $MainAnimation
	confirm_animation = $ConfirmAnimation
	cancel_animation = $CancelAnimation


func _on_reset_button_mouse_entered() -> void:
	var anim_names = main_animation.sprite_frames.get_animation_names()
	main_animation.play(anim_names[0])


func _on_reset_button_mouse_exited() -> void:
	await main_animation.animation_looped
	main_animation.stop()


func _on_reset_button_pressed() -> void:
	show_extra_icons(!current_visibility)


func _on_confirm_button_pressed() -> void:
	get_tree().reload_current_scene()


func _on_cancel_button_pressed() -> void:
	show_extra_icons(!current_visibility)


func show_extra_icons(val: bool):
	current_visibility = val
	confirm_animation.visible = val
	cancel_animation.visible = val
