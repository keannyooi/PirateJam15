class_name CardDeckHUD
extends Control

@export var card_scene: PackedScene

@onready var deck_display: HBoxContainer = %DeckDisplay


func display_deck() -> void:
	for card_id in PlayerStats.card_id_deck:
		var card: Card = card_scene.instantiate()
		card.setup(card_id, CardSystem.has_inverse_card(card_id))
		
		deck_display.add_child(card)
		
	

func add_card_to_deck(id: String) -> void:
	var card: Card = card_scene.instantiate()
	card.setup(id, CardSystem.has_inverse_card(id))
	
	deck_display.add_child(card)
	PlayerStats.add_card_to_deck(id)
	
	# check for card flips
	for deck_card in deck_display.get_children():
		if deck_card.is_flippable and \
		CardSystem.get_card_inverse(deck_card.card_id) == id:
			deck_card.flip()
			PlayerStats.flip_card(deck_card.unique_id)
			
	

func clean_deck() -> void:
	for card in deck_display.get_children():
		card.queue_free()
	
