extends Node

@onready var attributes: Attributes = load("res://entities/player/DefaultPlayerAttributes.tres")
@onready var buffs: BuffAttributes = load("res://entities/player/DefaultPlayerBuffAttributes.tres")
@onready var start_deck: Deck = load("res://entities/player/DefaultPlayerDeck.tres")

const BASIC = CardManager.CardType.BASIC
const BLOOD = CardManager.CardType.BLOOD
const FIRE = CardManager.CardType.FIRE
const EARTH = CardManager.CardType.EARTH
const WATER = CardManager.CardType.WATER
const AIR = CardManager.CardType.AIR
const SHADOW = CardManager.CardType.SHADOW

@export var hp: float = 0.0
@export var atk: float = 0.0
@export var def: float = 0.0
@export var mys: float = 0.0
@export var res: float = 0.0
@export var spd: float = 0.0
@export var hp_max: float = 0.0
@export var def_block: float = 0.0
@export var res_block: float = 0.0

var completed_nodes: Array[MapNode] = []
var event_decisions: Dictionary = {}
#var is_main_deck_full: bool = false
@export var max_main_deck_size = 5
var main_deck_size = 0
var main_deck: Dictionary = {}
var battle_deck: Dictionary = {}
var side_deck: Dictionary = {}

var current_floor: int = 0
var current_node_id: int = 0


func _ready() -> void:
	for card in start_deck.deck:
		for i in range(start_deck.deck[card]):
			add_card_to_deck(card)

# main functions
func add_card_to_deck(id: String) -> void:
	if is_main_deck_full():
		add_to_side_deck(id)
	else:
		add_to_main_deck(id)
	

func mark_current_node_complete() -> void:
	completed_nodes.append(current_node_id)
	

func move_card_to_side_deck(id: String) -> void:
	main_deck[id] -= 1
	main_deck_size -= 1
	battle_deck[id] -= 3
	if not main_deck[id]:
		main_deck.erase(id)
		battle_deck[id].erase(id)
	
	add_to_side_deck(id)
	

func move_card_to_main_deck(id: String) -> void:
	if is_main_deck_full():
		side_deck[id] -= 1
		if side_deck[id] == 0:
			side_deck.erase(id)
		
		add_to_main_deck(id)
	
# helper functions
func is_main_deck_full() -> bool:
	if main_deck_size < max_main_deck_size:
		return false
	return true
	
func add_to_main_deck(id: String) -> void:
	main_deck_size += 1
	if main_deck.get(id) != null:
		main_deck[id] += 1
		battle_deck[id] += 3
	else:
		main_deck[id] = 1
		battle_deck[id] = 3

func add_to_side_deck(id: String) -> void:
	if side_deck.get(id) != null:
		side_deck[id] += 1
	else:
		side_deck[id] = 1
	
func recover_hp(amount: float) -> void:
	hp = min(hp + amount, hp_max) 
	$HPComponent.update(hp)
	
func setAttributes(floor_level, egoArray):
	var total_ego = 0
	for ego in egoArray:
		total_ego += ego
	var base = floor_level + total_ego
	var shadow_value = 3 * egoArray[SHADOW]
	var basic_value = 3 * egoArray[BASIC]
	var total_value = 3 * total_ego
	hp_max = ((total_ego + egoArray[BLOOD] + base) * base) / (egoArray[SHADOW]+1)
	hp = hp_max
	atk = (egoArray[FIRE] + base + shadow_value) * base
	def = (egoArray[EARTH] + base) * base
	mys = (egoArray[WATER] + base) * base
	res = (egoArray[AIR] + base) * base
	spd = ((total_ego * base) + ((basic_value - total_value) / 2)) * (egoArray[BASIC]+1)
	

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
