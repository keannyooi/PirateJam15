class_name CardHandHUD
extends Control

@export var card_scene: PackedScene

@onready var end_turn_button: Button = %EndTurnButton
@onready var hand_display: HBoxContainer = %HandDisplay

const TWEEN_TIME: float = 1.0

var deck_array: Array[String] = []
var deck_discard: Array[String] = []
var max_hand_size: int = 5


func clean_hand() -> void:
	for card in hand_display.get_children():
		hand_display.remove_child(card)
		card.queue_free()
	

func draw_from_deck(amount: int) -> void:
	if deck_array.is_empty(): #shuffle only if deck is empty on start of card draw.
		shuffle_deck()
	for i in range(min(amount, len(deck_array))):
		var card_id: String = deck_array.pop_back()
		var card: Card = card_scene.instantiate()
		card.setup(hand_display.get_child_count(), card_id)
		
		card.incoming_rearrange.connect(rearrange_cards)
		
		hand_display.add_child(card)
		
	
	# flip one card of its opposing type if applicable
	#for hand_card in hand_display.get_children():
		#if hand_card.card_id == CardManager.get_card_inverse(id):
			#hand_card.flip()
			#PlayerData.flip_card(hand_card.unique_id)
			#break
			
	

func draw_new_cards() -> void:
	var card_count_in_hand: int = hand_display.get_child_count()
	draw_from_deck(max_hand_size - card_count_in_hand)
	

func hide_hand() -> void:
	# animate out the hud
	var tween: Tween = self.create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", 675, TWEEN_TIME)
	

func init_hand() -> void:
	self.position.y = 675
	
	populate_deck()
	#if CardManager.blood_type_card_ability_check(deck_array):
		#max_hand_size = 4
	
	refresh_hand()
	

func populate_deck() -> void:
	var temp_array: Array[String] = [];
	for card_id in PlayerData.main_deck.keys():
		temp_array.clear()
		temp_array.resize(PlayerData.battle_deck[card_id])
		temp_array.fill(card_id)
		
		deck_array.append_array(temp_array)
	

func rearrange_cards(from: Card, to: Card) -> void:
	if from.unique_id == to.unique_id: return # sanity check
	
	# physically change node order here
	hand_display.move_child(from, to.unique_id)
	
	var counter: int = 0
	for card in hand_display.get_children():
		if card.unique_id != counter:
			card.unique_id = counter
		
		counter += 1
	

func refresh_hand() -> void:
	deck_array.shuffle()
	print(deck_array)
	
	draw_from_deck(max_hand_size)
	

func remove_from_deck(card: Card) -> void:
	hand_display.remove_child(card)
	card.queue_free()

func play_card(card: Card) -> void:
	hand_display.remove_child(card)
	deck_discard.push_front(card.card_id)
	card.queue_free()

func shuffle_deck() -> void:
	#empty deck to discard
	while not deck_array.is_empty():
		deck_discard.push_front(deck_array.pop_back())
	#shuffle discard back into deck
	while not deck_discard.is_empty():
		var rand = randi_range(0, deck_discard.size()-1)
		deck_array.push_front(deck_discard.pop_at(rand))

func show_hand() -> void:
	# animate in the hud
	var tween: Tween = self.create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", 520, TWEEN_TIME)
	
	# draw_from_deck(5 - hand_display.get_child_count())
	
