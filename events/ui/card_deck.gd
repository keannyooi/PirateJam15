class_name CardDeckHUD
extends Control

@export var card_scene: PackedScene

@onready var deck_display: HBoxContainer = %DeckDisplay


func display_deck() -> void:
	for i in range(len(PlayerStats.card_deck)):
		var card: Card = card_scene.instantiate()
		card.setup(i, PlayerStats.card_deck[i])
		card.incoming_rearrange.connect(rearrange_cards)
		
		deck_display.add_child(card)
	

func add_card_to_deck(uid: int, id: String) -> void:
	var card: Card = card_scene.instantiate()
	card.setup(uid, id)
	
	deck_display.add_child(card)
	PlayerStats.add_card_to_deck(id)
	
	# flip one card of its opposing type if applicable
	for deck_card in deck_display.get_children():
		if deck_card.is_flippable and \
		deck_card.card_id == CardSystem.get_card_inverse(id):
			deck_card.flip()
			PlayerStats.flip_card(deck_card.unique_id)
			break
			
	

func clean_deck() -> void:
	for card in deck_display.get_children():
		deck_display.remove_child(card)
		card.queue_free()
	

func rearrange_cards(from: Card, to: Card) -> void:
	# sanity check
	if from.unique_id == to.unique_id: return
	
	PlayerStats.rearrange_cards(from.unique_id, to.unique_id)
	
	# physically change node order here
	deck_display.move_child(from, to.unique_id)
	
	var counter: int = 0
	for card in deck_display.get_children():
		if card.unique_id != counter:
			card.unique_id = counter
		
		counter += 1
	
