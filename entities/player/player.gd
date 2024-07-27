class_name Player
extends TextureRect

signal player_died

@onready var hp_component: HPComponent = $HPComponent


func _ready() -> void:
	hp_component.max_value = PlayerData.attributes.hp
	hp_component.update(PlayerData.attributes.hp)
	

func recover_hp(hp: float) -> void:
	PlayerData.attributes.hp += hp
	hp_component.update(PlayerData.attributes.hp)
	

func take_damage(damage: float) -> void:
	PlayerData.attributes.hp -= damage
	hp_component.update(PlayerData.attributes.hp)
	await hp_component.animation_timer.timeout
	
	if PlayerData.attributes.hp <= 0:
		player_died.emit()
	
