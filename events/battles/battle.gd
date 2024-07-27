class_name Battle
extends CanvasLayer

@export var ego_slot_scene: PackedScene
@export var floor_number: int = 1

@onready var background_dim: ColorRect = $BackgroundDim
@onready var card_deselect_button: TextureButton = %CardDeselectButton
@onready var card_hand_hud: CardHandHUD = $CardHandHUD
@onready var ego_display_hud: EGODisplayHUD = $EGODisplayHUD
@onready var enemies_node: Control = $Enemies
@onready var floor_label: Label = %FloorLabel
@onready var player: Player = $Player
@onready var turn_label: Label = %TurnLabel

var attack_order: Array = []
var current_turn = 0
var current_card: Card
var enemies_array: Array = []
var ego: Array = [0, 0, 0, 0, 0, 0, 0]
var ego_multiplier: Array = [0, 0, 0, 0, 0, 0, 0]


func _ready() -> void:
	if enemies_node.get_child_count() < 1:
		push_error("ERROR: no enemies found as children of Enemies node")
		return
	
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
	
	# start battle
	init_player_phase()
	

# each phase of game loop is its own function and loops back into each other
# here they are sorted by order of precendence
func init_player_phase() -> void:
	current_turn += 1
	turn_label.text = "Turn %d" % current_turn
	card_hand_hud.end_turn_button.disabled = true
	
	ego = ego_multiplier.duplicate(true)
	ego_display_hud.update_ego(ego)
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
	if card.function != CardManager.CardFunction.ATK:
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
	card_hand_hud.end_turn_button.disabled = false
	deselect_card()
	
	# use up ego
	var total_cost: int = current_card.cost_array.reduce(sum_lambda)
	CardManager.subtract_ego(ego, current_card.cost_array)
	
	match current_card.function:
		CardManager.CardFunction.ATK:
			enemy.take_damage((total_cost + 1) * ego_multiplier[current_card.type])
		CardManager.CardFunction.DEF:
			PlayerData.attributes.def += (total_cost + 1) * ego_multiplier[current_card.type]
		_:
			pass
	
	GlobalSignalBus.play_card.emit(current_card)
	card_hand_hud.remove_from_deck(current_card)
	ego_display_hud.update_ego(ego)
	

func enemy_phase() -> void:
	card_hand_hud.hide_hand()
	
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
		match CardManager.get_card_function(card_id):
			CardManager.CardFunction.ATK:
				player.take_damage((total_cost + 1) \
					* ego_multiplier[type])
			CardManager.CardFunction.DEF:
				enemy.attributes.def += (total_cost + 1) \
					* ego_multiplier[type]
			_:
				pass
		
		await get_tree().create_timer(1).timeout
		
		# check for lose condition
		if PlayerData.attributes.hp <= 0:
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
	
	# 3 cards = 1 EGO
	for i in range(len(ego_multiplier)):
		ego_multiplier[i] /= 3
	

func player_victory() -> void:
	print("A WINNER IS YOU")
	card_hand_hud.hide_hand()
	

func sum_lambda(a: int, b: int) -> int:
	return a + b
