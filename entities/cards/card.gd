class_name Card
extends TextureRect

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var unique_id: int = 0
var card_id: String = ""
var is_flippable: bool = false


# this is meant to be the constructor function
func setup(id: String, flippable: bool) -> Card:
	unique_id = len(PlayerStats.card_id_deck)
	card_id = id
	is_flippable = flippable
	
	return self
	

func flip() -> void:
	if not is_flippable: return
	
	card_id = CardSystem.details_dict[card_id]["inverse"]
	
	# and now, physically flipping the damn thing
	animation_player.play("flip")
	
