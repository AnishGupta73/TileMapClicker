class_name ClickStructData
extends Resource

@export var group : String = ""
@export var length : int = 0
@export var location : Vector2i = Vector2i(0, 0)

func _init(g : String = "", len : int = 0, loc : Vector2i = Vector2i(0, 0)):
	group = g
	length = len
	location = loc
