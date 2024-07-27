class_name EGOSlot
extends TextureRect

signal incoming_rearrange(from: EGOSlot, to: EGOSlot)

@export var unique_id: int = 0
@export var type: CardManager.CardType = CardManager.CardType.BASIC

@onready var temp_label: Label = $Label

var energy_level: int = 0


func update_energy_level(level: int) -> void:
	if energy_level == 0 and level > 0:
		# glow up
		pass
	if energy_level > 0 and level == 0:
		# dim down
		pass
	
	energy_level = level
	temp_label.text = str(energy_level)
	

# the following functions allow the card to be dragged & dropped
func _can_drop_data(_at_position: Vector2, data) -> bool:
	return data is EGOSlot
	

func _drop_data(_at_position: Vector2, data) -> void:
	incoming_rearrange.emit(data, self)
	

func _get_drag_data(_at_position: Vector2) -> EGOSlot:
	#print("dragging card at position (%f, %f)" % [at_position.x, at_position.y])
	
	var preview = TextureRect.new()
	preview.texture = self.texture
	preview.texture.region = self.texture.region
	
	self.set_drag_preview(preview)
	return self
	
