class_name Enemy
extends Button

@export var attributes: Attributes
@export var buffs: BuffAttributes
@export var deck_dict: Dictionary
@export var deck_array: Array[String] = []
# @export var advanced_decision_machine

@onready var hp_component: HPComponent = $HPComponent
@onready var selection_arrow: TextureRect = $SelectionArrow

var ego: Array[int] = [0, 0, 0, 0, 0, 0, 0]
var energy: Array[int] = [0, 0, 0, 0, 0, 0, 0]
var hand_array: Array[String] = []
var max_hand_size: int = 3


func _ready() -> void:
	selection_arrow.hide()
	hp_component.max_value = attributes.hp
	hp_component.update(attributes.hp)
	
	populate_deck()
	#if CardManager.blood_type_card_ability_check(deck_array):
		#max_hand_size = 4
	
	refresh_hand()
	init_ego()
	

func connect_signals() -> void:
	self.mouse_entered.connect(focus_enemy)
	self.focus_entered.connect(focus_enemy)
	self.mouse_exited.connect(unfocus_enemy)
	self.focus_exited.connect(unfocus_enemy)
	self.pressed.connect(on_selected)
	

func disconnect_signals() -> void:
	if not self.mouse_entered.is_connected(focus_enemy): return
	
	self.mouse_entered.disconnect(focus_enemy)
	self.focus_entered.disconnect(focus_enemy)
	self.mouse_exited.disconnect(unfocus_enemy)
	self.focus_exited.disconnect(unfocus_enemy)
	self.pressed.disconnect(on_selected)
	

func draw_from_deck(amount: int) -> void:
	for i in range(min(amount, len(deck_array))):
		var card_id: String = deck_array.pop_back()
		hand_array.append(card_id)
	

func focus_enemy() -> void:
	selection_arrow.show()
	

func init_ego() -> void:
	# tally cards by type
	for card_id in deck_dict.keys():
		var type: CardManager.CardType = CardManager.get_card_type(card_id)
		ego[type] += deck_dict[card_id]
	
	# 3 cards = 1 EGO
	for i in range(len(ego)):
		ego[i] /= 3
	

func on_selected() -> void:
	GlobalSignalBus.select_enemy.emit(self)
	

func populate_deck() -> void:
	var temp_array: Array[String] = [];
	for card_id: String in deck_dict.keys():
		temp_array.clear()
		temp_array.resize(deck_dict[card_id])
		temp_array.fill(card_id)
		
		deck_array.append_array(temp_array)
	

func recover_hp(hp: float) -> void:
	attributes.hp = min(attributes.hp + hp, attributes.hp_max) 
	hp_component.update(attributes.hp)
	

func refresh_hand() -> void:
	deck_array.shuffle()
	
	draw_from_deck(max_hand_size)
	

func run_decision_tree() -> String:
	var chosen_card_id: String = ""
	energy = ego.duplicate(true)
	
	# placeholder for actual ai implementation
	chosen_card_id = hand_array.pick_random()
	
	return chosen_card_id
	

func take_atk_damage(damage: float) -> void:
	attributes.hp = max(0, attributes.hp - damage)
	hp_component.update(attributes.hp)
	await hp_component.animation_timer.timeout
	
	if attributes.hp <= 0:
		# enemy defeated
		GlobalSignalBus.enemy_defeated.emit(self)
	
func take_mys_damage(damage: float) -> void:
	attributes.hp = max(0, attributes.hp - damage)
	hp_component.update(attributes.hp)
	await hp_component.animation_timer.timeout
	
	if attributes.hp <= 0:
		# enemy defeated
		GlobalSignalBus.enemy_defeated.emit(self)
	

func unfocus_enemy() -> void:
	selection_arrow.hide()
	
