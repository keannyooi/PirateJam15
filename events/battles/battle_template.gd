class_name Battle
extends Node2D

@onready var card_deck_hud: CardDeckHUD = $CardDeckHUD

var ego: Dictionary = {
	"basic": 0,
	"fire": 0,
	"water": 0,
	"earth": 0,
	"air": 0,
	"blood": 0,  # long ago, the seven nations lived in harmony
	"shadow": 0, # but everything changed when the shadow nation attacked
}



func _ready() -> void:
	card_deck_hud.display_deck()
	
	# set up energy levels at the start of turn
	for card in card_deck_hud.get_children():
		pass
	
