class_name Enemy
extends Sprite2D

@export var attributes: Attributes

@onready var hp_component: HPComponent = $HPComponent


func _ready() -> void:
	hp_component.max_value = attributes.hp
	hp_component.update(attributes.hp)
	

func take_damage(damage: float) -> void:
	attributes.hp -= damage
	hp_component.update(attributes.hp)
	

func recover_hp(hp: float) -> void:
	attributes.hp += hp
	hp_component.update(attributes.hp)
	
