class_name CardHandHUD
extends Control

@export var card_scene: PackedScene

@onready var hand_display: HBoxContainer = %HandDisplay

const TWEEN_TIME: float = 1.0

var deck_array: Array[String] = []


func clean_hand() -> void:
	for card in hand_display.get_children():
		hand_display.remove_child(card)
		card.queue_free()
	

func draw_from_deck(amount: int) -> void:
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
			
	

func hide_hand() -> void:
	# animate out the hud
	var tween: Tween = self.create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", 675, TWEEN_TIME)
	

func init_hand() -> void:
	self.position.y = 675
	
	populate_deck()
	refresh_hand()
	

func populate_deck() -> void:
	for card_id in PlayerData.main_deck.keys():
		var temp_array: Array[String] = [];
		temp_array.resize(PlayerData.main_deck[card_id])
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
	
	draw_from_deck(5)
	

func show_hand() -> void:
	# animate in the hud
	var tween: Tween = self.create_tween() \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", 520, TWEEN_TIME)
	
	# draw_from_deck(5 - hand_display.get_child_count())
	
