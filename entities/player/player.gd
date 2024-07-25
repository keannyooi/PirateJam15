class_name Player
extends Sprite2D

@onready var hp_component: HPComponent = $HPComponent


func _ready() -> void:
	hp_component.max_value = PlayerData.attributes.hp
	hp_component.update(PlayerData.attributes.hp)
	

# fyi this function supports debuffing attributes by setting amount
# as a negative number
func edit_attribute(attribute: String, amount: int) -> void:
	match attribute:
		"atk":
			PlayerData.attributes.atk += amount
		"def":
			PlayerData.attributes.def += amount
		"mys":
			PlayerData.attributes.mys += amount
		"res":
			PlayerData.attributes.res += amount
		_:
			push_error("ERROR: atk, def, mys or res expected")
	

func recover_hp(hp: float) -> void:
	PlayerData.attributes.hp += hp
	hp_component.update(PlayerData.attributes.hp)
	

func take_damage(damage: float) -> void:
	PlayerData.attributes.hp -= damage
	hp_component.update(PlayerData.attributes.hp)
	


