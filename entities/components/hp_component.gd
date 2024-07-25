class_name HPComponent
extends ProgressBar

const HEALTH_BAR_ANIM_TIME: float = 0.5


func update(hp: float) -> void:
	var tween: Tween = self.create_tween()\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "value", hp, HEALTH_BAR_ANIM_TIME)
	
