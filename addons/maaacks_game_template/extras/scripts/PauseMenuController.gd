class_name PauseMenuController
extends Node
## Node for opening a pause menu when detecting a 'ui_cancel' event.

@export var pause_menu_packed : PackedScene
@export var pause_button : Button

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		open_pause_menu()
	

func _ready() -> void:
	InGameMenuController.scene_tree = get_tree()
	
	if pause_button:
		pause_button.pressed.connect(open_pause_menu)
	

func open_pause_menu() -> void:
	InGameMenuController.open_menu(pause_menu_packed, get_viewport())
	
