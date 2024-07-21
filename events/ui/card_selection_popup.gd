class_name CardSelectionPopup
extends Control

signal card_selected

@onready var card_container: HBoxContainer = %CardContainer
@onready var card_description: Label = %CardDescription
@onready var card_name: Label = %CardName

const POPUP_ANIMATION_DURATION: float = 0.5

var original_pos_y: float = 0.0


func _ready() -> void:
	original_pos_y = self.position.y
	self.position.y += 500
	
	self.hide()
	

func prompt_card_choice(card_id_array: Array[String]) -> void:
	for card_id in card_id_array:
		# using buttons in place of cards for now
		var test_button = Button.new()
		test_button.text = card_id
		test_button.pressed.connect(select_card.bind(card_id))
		test_button.mouse_entered.connect(show_card_description.bind(card_id))
		
		test_button.set_anchors_preset(LayoutPreset.PRESET_HCENTER_WIDE)
		
		card_container.add_child(test_button)
	
	self.show()
	
	var tween: Tween = self.create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", original_pos_y, \
		POPUP_ANIMATION_DURATION)
	

func select_card(card_id: String) -> void:
	print(card_id)
	card_selected.emit(card_id)
	
	var tween: Tween = self.create_tween().set_ease(Tween.EASE_OUT) \
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "position:y", original_pos_y + 500, \
		POPUP_ANIMATION_DURATION)
	

func show_card_description(card_id: String) -> void:
	card_name.text = CardSystem.get_card_name(card_id)
	card_description.text = CardSystem.get_card_description(card_id)
	
