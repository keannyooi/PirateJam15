extends Node

var event_decisions: Dictionary = {}
var is_main_deck_full: bool = false
var main_deck: Dictionary = {
	"basic_atk": 2,
	"fire_def": 1
}
var side_deck: Dictionary = {}


func add_card_to_deck(id: String) -> void:
	if is_main_deck_full:
		add_to_side(id)
	else:
		add_to_main(id)
	

func add_to_main(id: String) -> void:
	if not main_deck[id]:
		main_deck[id] = 1
	else:
		main_deck[id] += 1
	

func add_to_side(id: String) -> void:
	if not side_deck[id]:
		side_deck[id] = 1
	else:
		side_deck[id] += 1
	

func move_card_to_side(id: String) -> void:
	main_deck[id] -= 1
	if not main_deck[id]:
		main_deck.erase(id)
	
	add_to_side(id)
	

func move_card_to_main(id: String) -> void:
	side_deck[id] -= 1
	if not side_deck[id]:
		side_deck.erase(id)
	
	add_to_main(id)
	

#func flip_card(id: int) -> void:
	#main_deck[id] -= 1
	#
	#main_deck[unique_id] = CardSystem.get_card_inverse(main_deck[unique_id])
	#

#func rearrange_cards(from: int, to: int) -> void:
	#print("from %d to %d" % [from, to])
	#
	## sanity check
	#if from == to: return
	#
	## i'd spent hours trying to come up with an elegant solution to this
	## only to realize you can just do the ol' pop and insert
	#var temp_id: String = main_deck.pop_at(from)
	#main_deck.insert(to, temp_id)
	#
	#print(main_deck)
	#

# RIP my old solution, you will forever be remembered
#var temp_id: String = card_deck[from]
#var increment: int = from < to as int
#if increment == 0: increment = -1
#
#for i in range(from, to, increment):
	#card_deck[i] = card_deck[i + increment]
#
#card_deck[to] = temp_id
