extends CharacterBody2D
class_name Player


func _ready():
	pass # Replace with function body.


func _unhandled_key_input(event: InputEvent):
	if event.is_released(): return
	
	Input.get_axis("move_left", "move_right")
