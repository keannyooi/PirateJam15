class_name Event
extends Node2D

@export var EVENT_ID: String
@export var CARD_ID_ARRAY: Array[String]
@export var NEXT_EVENT_LINK: String

@onready var card_selection_popup: CardSelectionPopup = $CardSelectionPopup
@onready var narration_system: NarrationSystem = $NarrationSystem

#These allow interfacing with scenes that call this one.
var parent
var next_event

func _ready():
	# hide the popup first
	card_selection_popup.hide()
	
	card_selection_popup.card_selected.connect(select_card)
	
	# play through opening narration
	narration_system.start_narration("opening")
	await narration_system.narration_finished
	
	card_selection_popup.prompt_card_choice(CARD_ID_ARRAY)
	

func select_card(card_id: String) -> void:
	PlayerData.add_card_to_deck(card_id)
	
	# play through closing narration
	narration_system.start_narration("closing")
	await narration_system.narration_finished
	
	print("transition to next event")
	next_event.show()
	parent.remove_child(self)
	#get_tree().change_scene_to_file("res://util/map_navigation/map_navigation.tscn")
