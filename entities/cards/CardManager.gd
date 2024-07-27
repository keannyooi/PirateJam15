extends Node

enum CardType {BASIC, FIRE, WATER, EARTH, AIR, BLOOD, SHADOW}
enum CardFunction {ATK, DEF}
# long ago, the seven nations lived in harmony
# but everything changed when the shadow nation attacked
const CARD_DETAILS_FILE_PATH = "res://entities/cards/card_details.json"
const CARD_ATLAS_FILE_PATH = "res://assets/sprites/card_atlas.tres"

@onready var card_atlas: AtlasTexture = load(CARD_ATLAS_FILE_PATH)

var details_dict: Dictionary = {}


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
	

func blood_type_card_ability_check(deck: Array[String]) -> bool:
	var has_blood_type_card: bool = false
	
	for card_id in deck:
		var type: CardManager.CardType = CardManager.get_card_type(card_id)
		if type == CardManager.CardType.BLOOD:
			has_blood_type_card = true
			break
	
	return has_blood_type_card
	

func get_atlas_coords(card_id: String) -> Vector2:
	return Vector2i(
		details_dict[card_id].atlas_coord_x,
		details_dict[card_id].atlas_coord_y
	)
	

func get_card_cost(card_id: String) -> Array:
	return details_dict[card_id].cost
	

func get_card_description(card_id: String) -> String:
	return details_dict[card_id].description
	

func get_card_function(card_id: String) -> CardFunction:
	return details_dict[card_id].function
	

func get_card_name(card_id: String) -> String:
	return details_dict[card_id].name
	

func get_card_inverse(card_id: String) -> String:
	return details_dict[card_id].inverse
	

func get_card_type(card_id: String) -> CardType:
	return details_dict[card_id].type
	

func has_sufficient_ego(ego: Array, cost_array: Array) -> bool:
	print(ego)
	
	var ego_duplicate: Array = ego.duplicate(true)
	var is_sufficient: bool = true
	for i in range(len(cost_array)):
		if ego_duplicate[i] >= cost_array[i]:
			ego_duplicate[i] -= cost_array[i]
		elif i != CardType.BASIC \
		and ego_duplicate[CardType.BASIC] + ego_duplicate[i] >= cost_array[i]:
			# use basic ego as a substitute
			ego_duplicate[CardType.BASIC] -= cost_array[i] - ego_duplicate[i]
			ego_duplicate[i] = 0
		else:
			is_sufficient = false
			break
	
	print(ego_duplicate)
	print(ego)
	
	return is_sufficient
	

func subtract_ego(ego: Array, cost_array: Array) -> void:
	for i in range(len(cost_array)):
		if ego[i] >= cost_array[i]:
			ego[i] -= cost_array[i]
		elif i != CardType.BASIC:
			# use basic ego as a substitute
			ego[CardType.BASIC] -= cost_array[i] - ego[i]
			ego[i] = 0
	
