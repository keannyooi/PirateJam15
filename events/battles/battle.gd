class_name Battle
extends CanvasLayer

@export var ego_slot_scene: PackedScene
@export var floor_number: int = 1
@export var CARD_ID_ARRAY: Array[String] #Cards for battle victory

@onready var background_dim: ColorRect = $BackgroundDim
@onready var card_deselect_button: TextureButton = %CardDeselectButton
@onready var card_hand_hud: CardHandHUD = $CardHandHUD
@onready var ego_display_hud: EGODisplayHUD = $EGODisplayHUD
@onready var enemies_node: Control = $Enemies
@onready var floor_label: Label = %FloorLabel
@onready var player: Player = $Player
@onready var turn_label: Label = %TurnLabel
@onready var card_selection_popup: CardSelectionPopup = $CardSelectionPopup

var attack_order: Array = []
var current_turn = 0
var current_card: Card
var enemies_array: Array = []
var ego: Array = [0, 0, 0, 0, 0, 0, 0] #is modified
var ego_multiplier: Array = [0, 0, 0, 0, 0, 0, 0]



#These allow interfacing with scenes that call this one.
var parent
var next_event


func _ready() -> void:
	if enemies_node.get_child_count() < 1:
		push_error("ERROR: no enemies found as children of Enemies node")
		return
	card_selection_popup.hide()
	card_selection_popup.card_selected.connect(choose_card)
	# connect signals
	GlobalSignalBus.enemy_defeated.connect(handle_enemy_defeat)
	GlobalSignalBus.select_card.connect(card_selected_phase)
	GlobalSignalBus.select_enemy.connect(execution_phase)
	card_hand_hud.end_turn_button.pressed.connect(enemy_phase)
	card_deselect_button.pressed.connect(deselect_card)
	
	# initializing some stuff
	background_dim.hide()
	enemies_array = enemies_node.get_children()
	card_hand_hud.init_hand()
	floor_label.text = "Floor %d" % floor_number
	
	# set up ego values before starting the battle
	init_ego()
	
	# set up player attributes before starting the battle
	PlayerData.setAttributes(floor_number, ego_multiplier)
	
	# start battle
	init_player_phase()
	

# each phase of game loop is its own function and loops back into each other
# here they are sorted by order of precendence
func init_player_phase() -> void:
	current_turn += 1
	turn_label.text = "Turn %d" % current_turn
	card_hand_hud.end_turn_button.disabled = false
	
	ego = ego_multiplier.duplicate(true)
	ego_display_hud.update_ego(ego)
	#reset player defense
	PlayerData.def_block = 0
	PlayerData.res_block = 0
	#check if deck is empty
	if card_hand_hud.deck_array.is_empty():
		card_hand_hud.shuffle_deck()
	card_hand_hud.draw_new_cards()
	card_hand_hud.show_hand()
	

func card_selected_phase(card: Card):
	print("selected " + card.card_id)
	current_card = card
	
	# calculating total available ego
	if not CardManager.has_sufficient_ego(ego, card.cost_array):
		print("you got no energy for that my man")
		return
	
	# skip enemy selection if card selected isn't an attack card
	if card.target != CardManager.CardTarget.TARGET:
		execution_phase()
		return
	
	# prepare for enemy selection
	background_dim.show()
	for enemy in enemies_array:
		enemy.z_index = 1
		enemy.connect_signals()
	

func deselect_card() -> void:
	background_dim.hide()
	for enemy in enemies_array:
		enemy.z_index = 0
		enemy.selection_arrow.hide()
		enemy.disconnect_signals()
	

func execution_phase(enemy: Enemy = null) -> void:
	# exit out of enemy select screen, if it ever showed up
	deselect_card()
	
	# use up ego
	CardManager.subtract_ego(ego, current_card.cost_array)
	
	if current_card.function[CardManager.CardFunction.HP] != 0:
		PlayerData.recover_hp(calculate_hp_change(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier)) 
	if current_card.function[CardManager.CardFunction.SPD] != 0:
		PlayerData.speed += (calculate_spd_change(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier))
	if current_card.function[CardManager.CardFunction.DEF] != 0:
		PlayerData.def_block += calculate_def_block(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier)
	if current_card.function[CardManager.CardFunction.RES] != 0:
		PlayerData.res_block += calculate_res_block(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier)
	if current_card.function[CardManager.CardFunction.ATK] != 0 and enemy != null:
		enemy.take_atk_damage(calculate_atk_damage(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier))
	if current_card.function[CardManager.CardFunction.MYS] != 0 and enemy != null:
		enemy.take_mys_damage(calculate_mys_damage(floor_number, PlayerData.main_deck_size, \
			PlayerData.atk, PlayerData.buffs.atk, ego_multiplier))
	if current_card.function[CardManager.CardFunction.DRW] != 0:
		card_hand_hud.draw_from_deck(current_card.function[CardManager.CardFunction.DRW])
		
	
	GlobalSignalBus.play_card.emit(current_card)
	card_hand_hud.play_card(current_card)
	ego_display_hud.update_ego(ego)
	
func calculate_hp_change(floor_level, deck_size, hp, buff, _egos) -> int:
	var base = floor_level + deck_size
	var card_use_value = (hp * buff) / base 
	return card_use_value
	#var ego_boost = egos[CardManager.CardType.BLOOD] + 1
	#return(card_use_value * ego_boost)
	
func calculate_spd_change(floor_level, deck_size, speed, buff, egos) -> int:
	var base = floor_level + deck_size
	var card_use_value = (speed * buff) / base 
	var ego_boost = egos[CardManager.CardType.BASIC] + 1
	return(card_use_value * ego_boost)
	
func calculate_atk_damage(floor_level, deck_size, attack, buff, egos) -> int:
	var base = floor_level + deck_size
	var card_use_value = (attack * buff) / base 
	var ego_boost = (egos[CardManager.CardType.FIRE] + 1) * (egos[CardManager.CardType.SHADOW] + 1)
	return(card_use_value * ego_boost)
	
func calculate_mys_damage(floor_level, deck_size, Mystical, buff, egos) -> int:
	var base = floor_level + deck_size
	var card_use_value = (Mystical * buff) / base 
	var ego_boost = egos[CardManager.CardType.WATER] + 1
	return(card_use_value * ego_boost)
	
func calculate_def_block(floor_level, deck_size, defense, buff, egos) -> int:
	var base = floor_level + deck_size
	var defense_action_reduction = (defense * buff) / base 
	var ego_boost = egos[CardManager.CardType.EARTH] + 1
	return(defense_action_reduction * ego_boost)
	
func calculate_res_block(floor_level, deck_size, resistance, buff, egos) -> int:
	var base = floor_level + deck_size
	var defense_action_reduction = (resistance * buff) / base 
	var ego_boost = egos[CardManager.CardType.AIR] + 1
	return(defense_action_reduction * ego_boost)

func enemy_phase() -> void:
	card_hand_hud.hide_hand()
	card_hand_hud.end_turn_button.disabled = true
	
	# enemy battle sequence here
	var card_id: String
	var cost_array: Array
	var type: CardManager.CardType
	var total_cost: int
	
	for enemy: Enemy in enemies_array:
		# get played card info
		card_id = enemy.run_decision_tree()
		cost_array = CardManager.get_card_cost(card_id)
		type = CardManager.get_card_type(card_id)
		
		# subtract ego according to card played
		total_cost = cost_array.reduce(sum_lambda)
		CardManager.subtract_ego(ego, cost_array)
		
		# process card effects
		var card_function = CardManager.get_card_function(card_id)
		if card_function[CardManager.CardFunction.HP] != 0:
			enemy.recover_hp(calculate_hp_change(floor_number, enemy.deck_dict.size(), enemy.attributes.hp, enemy.buffs.hp, enemy.ego)) 
		if card_function[CardManager.CardFunction.SPD] != 0:
			enemy.recover_hp(calculate_spd_change(floor_number, enemy.deck_dict.size(), enemy.attributes.hp, enemy.buffs.hp, enemy.ego))
		if card_function[CardManager.CardFunction.ATK] != 0 and enemies_node.get_child_count() > 0:
			player.take_atk_damage(calculate_atk_damage(floor_number, enemy.deck_dict.size(), enemy.attributes.atk, enemy.buffs.atk, enemy.ego))
		if card_function[CardManager.CardFunction.DEF] != 0:
			enemy.attributes.def_block += calculate_def_block(floor_number, enemy.deck_dict.size(), enemy.attributes.def, enemy.buffs.def, enemy.ego)
		if card_function[CardManager.CardFunction.MYS] != 0 and enemies_node.get_child_count() > 0:
			player.take_atk_damage(calculate_mys_damage(floor_number, enemy.deck_dict.size(), enemy.attributes.mys, enemy.buffs.mys, enemy.ego))
		if card_function[CardManager.CardFunction.RES] != 0:
			enemy.attributes.res_block += calculate_res_block(floor_number, enemy.deck_dict.size(), enemy.attributes.res, enemy.buffs.res, enemy.ego)
		
		await get_tree().create_timer(1).timeout
		
		# check for lose condition
		if PlayerData.hp <= 0:
			game_over()
			return
	
	# enemy phase over, player's turn
	init_player_phase()
	

# helper functions
func game_over() -> void:
	print("YOU DIED")
	
	card_hand_hud.hide_hand()
	player.queue_free()
	

func handle_enemy_defeat(enemy: Enemy) -> void:
	print("enemy ded")
	
	enemies_array.erase(enemy)
	enemies_node.remove_child(enemy)
	enemy.queue_free()
	
	# check for win condition
	if enemies_node.get_child_count() < 1:
		# you win
		player_victory()
	

func init_ego() -> void:
	# tally cards by type
	var type: CardManager.CardType
	for card_id in PlayerData.main_deck.keys():
		type = CardManager.get_card_type(card_id)
		ego_multiplier[type] += PlayerData.main_deck[card_id]
	
	# 3 cards = 1 EGO	#Fixed this so each card in the main deck is 1 ego
	#for i in range(len(ego_multiplier)):
		#ego_multiplier[i] /= 3
	

func player_victory() -> void:
	print("A WINNER IS YOU")
	card_hand_hud.hide_hand()
	card_selection_popup.prompt_card_choice(CARD_ID_ARRAY)

func choose_card(card_id: String) -> void:
	
	PlayerData.add_card_to_deck(card_id)
	
	next_event.show()
	parent.remove_child(self)

func sum_lambda(a: int, b: int) -> int:
	return a + b
