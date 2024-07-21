extends Node

var card_id_deck: Array[String] = ["1"]
var event_decisions: Dictionary = {}

func add_card_to_deck(id: String) -> void:
	card_id_deck.append(id)
	

func flip_card(i: int) -> void:
	var card_id = card_id_deck[i]
	card_id_deck[i] = CardSystem.details_dict[card_id]["inverse"]
	
