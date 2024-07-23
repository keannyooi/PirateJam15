extends Node

var card_deck: Array[String] = ["1", "2", "3"]
var event_decisions: Dictionary = {}


func add_card_to_deck(id: String) -> void:
	card_deck.append(id)
	

func flip_card(unique_id: int) -> void:
	card_deck[unique_id] = CardSystem.get_card_inverse(card_deck[unique_id])
	

func rearrange_cards(from: int, to: int) -> void:
	print("from %d to %d" % [from, to])
	
	# sanity check
	if from == to: return
	
	# i'd spent hours trying to come up with an elegant solution to this
	# only to realize you can just do the ol' pop and insert
	var temp_id: String = card_deck.pop_at(from)
	card_deck.insert(to, temp_id)
	
	print(card_deck)
	

# RIP my old solution, you will forever be remembered
#var temp_id: String = card_deck[from]
#var increment: int = from < to as int
#if increment == 0: increment = -1
#
#for i in range(from, to, increment):
	#card_deck[i] = card_deck[i + increment]
#
#card_deck[to] = temp_id
