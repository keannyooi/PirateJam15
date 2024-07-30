class_name Player
extends TextureRect

signal player_died

@onready var hp_component: HPComponent = $HPComponent


func _ready() -> void:
	hp_component.max_value = PlayerData.hp
	hp_component.update(PlayerData.hp)
	

func recover_hp(hp: float) -> void:
	PlayerData.hp = min(PlayerData.hp + hp, PlayerData.hp_max)
	hp_component.update(PlayerData.hp)

func take_atk_damage(damage: float) -> void:
	damage -= PlayerData.def_block
	if damage > 0:
		PlayerData.hp -= damage
		hp_component.update(PlayerData.hp)
	await hp_component.animation_timer.timeout
	
	if PlayerData.hp <= 0:
		player_died.emit()

func take_mys_damage(damage: float) -> void:
	damage -= PlayerData.res_block
	if damage > 0:
		PlayerData.hp -= damage
		hp_component.update(PlayerData.hp)
	await hp_component.animation_timer.timeout
	
	if PlayerData.hp <= 0:
		player_died.emit()
	
