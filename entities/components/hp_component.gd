class_name HPComponent
extends ProgressBar

@onready var animation_timer: Timer = $AnimationTimer

func update(hp: float) -> void:
	var tween: Tween = self.create_tween()\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "value", hp, animation_timer.wait_time)
	
	animation_timer.start()
	
