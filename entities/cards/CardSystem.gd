extends Node

const CARD_DETAILS_FILE_PATH = "res://entities/cards/card_details.json"

var details_dict: Dictionary


func _ready():
	# load card_details.json
	if not FileAccess.file_exists(CARD_DETAILS_FILE_PATH):
		push_error("ERROR: card details file doesn't exist at filepath " \
			+ CARD_DETAILS_FILE_PATH)
		return
	
	# convert FileAccess object to Dictionary
	var details_file = FileAccess.open(CARD_DETAILS_FILE_PATH,
		FileAccess.READ)
	details_dict = JSON.parse_string(details_file.get_as_text())
	details_file.close()
	

func get_atlas_coords(card_id: String) -> Vector2:
	return Vector2i(
		details_dict[card_id].atlas_coord_x,
		details_dict[card_id].atlas_coord_y
	)
	

func get_card_description(card_id: String) -> String:
	return details_dict[card_id].description
	

func get_card_name(card_id: String) -> String:
	return details_dict[card_id].name
	

func get_card_inverse(card_id: String) -> String:
	return details_dict[card_id].inverse
	

func has_inverse_card(card_id: String) -> bool:
	return details_dict[card_id].inverse != ""
	
