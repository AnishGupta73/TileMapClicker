extends Node2D

var click_cell_inst : PackedScene = preload("res://Scenes/click_cell.tscn")
var group: int
var drop_dir: Vector2i
var click_cell_array: Array

var cell_background_img: Vector2i = Vector2i(5, 1)
var cell_new_img: Vector2i = Vector2i(16, 0)

signal triggered_click(group:int, source_idx:int, drop_direction:Vector2i, image:Vector2i)


func generate_Struct(size:int, group_to_set:int, growth_dir: Vector2i, drop_dir_to_set: Vector2i):
	group = group_to_set
	drop_dir = drop_dir_to_set
	var instance
	for i in range(size):
		instance = grab_instance()
		instance.position = Vector2(Vector2i(0, 0) + 16 * i * growth_dir)
		click_cell_array.append(instance)



func grab_instance():
	var instance = click_cell_inst.instantiate()
	add_child(instance)
	instance.mouse_entered_cell.connect(cell_entered)
	instance.mouse_clicked_cell.connect(cell_clicked)
	instance.set_image(cell_background_img)
	return instance


func cell_entered(source:Node):
	for cell in click_cell_array:
		if (cell == source):
			cell.set_image(cell_new_img)
		else:
			cell.set_image(cell_background_img)

func cell_clicked(source:Node):
	var index_in_group = click_cell_array.find(source)
	
	triggered_click.emit(group, index_in_group, drop_dir, cell_new_img)
