class_name HPComponent
extends ProgressBar

const HEALTH_BAR_ANIM_TIME: float = 0.5

@export var MAX_HP: float = 100.0

var hp = 0


func _ready() -> void:
	hp = MAX_HP
	self.max_value = MAX_HP
	self.value = hp
	

func animate_health_bar() -> void:
	var tween: Tween = self.create_tween()\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "value", hp, HEALTH_BAR_ANIM_TIME)
	

func recover_hp(recover_hp: float) -> void:
	hp += recover_hp
	
	animate_health_bar()
	

func take_damage(damage: float) -> void:
	hp -= damage
	
	animate_health_bar()
	
