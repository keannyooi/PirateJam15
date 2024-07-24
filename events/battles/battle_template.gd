class_name Battle
extends Node2D

@onready var card_hand_hud: CardHandHUD = $CardHandHUD
@onready var enemies_node: Node2D = $Enemies

var current_turn = 0
var enemies_array: Array = []
var ego: Array[int] = [0, 0, 0, 0, 0, 0, 0]


func _ready() -> void:
	#if enemies_node.get_child_count() < 1:
		#push_error("ERROR: no enemies found in Enemies node")
		#return
	
	enemies_array = enemies_node.get_children()
	card_hand_hud.init_hand()
	
	# set up energy levels at the start of turn
	for card: Card in card_hand_hud.hand_display.get_children():
		ego[card.type] += 1
	
	print(ego)
	# battle_loop()
	

func battle_loop() -> void:
	while true:
		match current_turn % (len(enemies_array) + 1):
			0: # player turn
				card_hand_hud.show_hand()
			_:
				pass
		
		current_turn += 1
	
