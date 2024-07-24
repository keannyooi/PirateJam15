class_name Card
extends TextureButton

signal incoming_rearrange(incoming: Card, original: Card)
signal play_card(card: Card)

@export var CARD_ATLAS: AtlasTexture

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var description_label: Label = %DesciprtionLabel
@onready var name_label: Label = %NameLabel
@onready var tooltip: MarginContainer = $Tooltip

var card_id: String = ""
var type: CardSystem.CardType = CardSystem.CardType.BASIC
var cost: int = 0
var old_position: Vector2
var unique_id: int = 0


func _ready() -> void:
	self.pressed.connect(focus_card)
	
	tooltip.hide()
	

# this is meant to be the constructor function
func setup(uid: int, id: String) -> Card:
	unique_id = uid
	card_id = id
	type = CardSystem.get_card_type(id)
	cost = CardSystem.get_card_cost(id)
	
	# each card needs to have its own atlas so that each atlas can be
	# individually edited
	self.texture_normal = CARD_ATLAS.duplicate()
	self.texture_normal.region.position = CardSystem.get_atlas_coords(id)
	
	return self
	

func flip() -> void:
	card_id = CardSystem.details_dict[card_id].inverse
	self.texture_normal.region.position = CardSystem.get_atlas_coords(card_id)
	
	# and now, physically flipping the damn thing
	animation_player.play("flip")
	

func focus_card() -> void:
	# temporary tooltip solution, may change later
	if tooltip.visible:
		tooltip.hide()
	else:
		for card in get_tree().get_nodes_in_group("cards"):
			card.tooltip.hide()
		
		tooltip.show()
		name_label.text = CardSystem.get_card_name(card_id)
		description_label.text = CardSystem.get_card_description(card_id)
	

# the following functions allow the card to be dragged & dropped
func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is Card
	

func _drop_data(_at_position: Vector2, data) -> void:
	# don't run the code below if the card drops on itself
	if data.unique_id == unique_id: return
	
	incoming_rearrange.emit(data, self)
	

func _get_drag_data(_at_position: Vector2) -> Card:
	#print("dragging card at position (%f, %f)" % [at_position.x, at_position.y])
	
	var preview = TextureRect.new()
	preview.texture = self.texture_normal
	preview.texture.region = self.texture_normal.region
	
	self.set_drag_preview(preview)
	return self
	
