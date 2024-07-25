class_name Battle
extends Node2D

@onready var card_hand_hud: CardHandHUD = $CardHandHUD
@onready var enemies_node: Node2D = $Enemies
@onready var player: Player = $Player

var attack_order: Array = []
var current_turn = 0
var enemies_array: Array = []
var energy: Array[int] = [0, 0, 0, 0, 0]
var ego: Array[int] = [0, 0, 0, 0, 0]


func _ready() -> void:
	if enemies_node.get_child_count() < 1:
		push_error("ERROR: no enemies found as children of Enemies node")
		return
	
	GlobalSignalBus.select_card.connect(card_selected_phase)
	
	enemies_array = enemies_node.get_children()
	card_hand_hud.init_hand()
	
	# set up energy levels at the start of turn
	update_ego()
	print(ego)
	
	# start battle
	init_player_phase()
	

# each phase of game loop is its own function and loops back into each other
# here they are sorted by order of precendence
func init_player_phase() -> void:
	card_hand_hud.show_hand()
	

func card_selected_phase(card: Card):
	print("selected " + card.card_id)
	
	# calculating total available energy
	var energy_threshold: int = energy[card.type]
	if card.type != CardManager.CardType.BASIC:
		energy_threshold += energy[CardManager.CardType.BASIC]
	
	if energy_threshold < card.cost:
		print("you got no energy for that my man")
		return
	
	execution_phase(card)
	

func execution_phase(card: Card) -> void:
	# use up energy
	if energy[card.type] >= card.cost:
		energy[card.type] -= card.cost
	elif card.type != CardManager.CardType.BASIC:
		# use basic energy as a subsitute
		energy[CardManager.CardType.BASIC] -= card.cost - energy[card.type]
		energy[card.type] = 0
	
	# process card effects
	match card.function:
		CardManager.CardFunction.ATK:
			enemies_array[0].take_damage((card.cost + 1) * ego[card.type])
		CardManager.CardFunction.DEF:
			player.edit_attribute("def", (card.cost + 1) * ego[card.type])
		_:
			pass
	
	card_hand_hud.remove_child(card)
	card.queue_free()
	

func enemy_phase() -> void:
	pass
	

func update_ego():
	for card: Card in card_hand_hud.hand_display.get_children():
		ego[card.type] += 1
		energy[card.type] += 1
	
