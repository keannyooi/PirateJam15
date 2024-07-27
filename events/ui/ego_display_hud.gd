class_name EGODisplayHUD
extends Control

@export var ego_slot_atlas: AtlasTexture
@export var ego_slot_scene: PackedScene

@onready var ego_slot_container: VBoxContainer = %EGOSlotContainer

const EGO_SLOT_ATLAS_COORDS: Dictionary = {
	CardManager.CardType.BASIC: Vector2(0, 0),
	CardManager.CardType.FIRE: Vector2(32, 0),
	CardManager.CardType.WATER: Vector2(0, 0),
	CardManager.CardType.EARTH: Vector2(0, 0),
	CardManager.CardType.AIR: Vector2(0, 0),
	CardManager.CardType.BLOOD: Vector2(0, 0),
	CardManager.CardType.SHADOW: Vector2(0, 0),
}


func _ready() -> void:
	# texture setup
	for slot in ego_slot_container.get_children():
		slot.texture = ego_slot_atlas.duplicate()
		slot.texture.region.position = EGO_SLOT_ATLAS_COORDS[slot.type]
	
		slot.incoming_rearrange.connect(rearrange_slots)
	

func update_ego(ego: Array) -> void:
	for slot in ego_slot_container.get_children():
		slot.update_energy_level(ego[slot.type])
		
		#if slot.energy_value == slot.type or \
		#(slot.type != CardManager.CardType.BASIC
		#and slot.type == CardManager.CardType.BASIC):
			#self.modulate.r = 1
			#self.modulate.g = 1
			#self.modulate.b = 1
		#else:
			#self.modulate.r = 0.5
			#self.modulate.g = 0.5
			#self.modulate.b = 0.5
	

func rearrange_slots(from: EGOSlot, to: EGOSlot) -> void:
	if from.unique_id == to.unique_id: return # sanity check
	
	# physically change node order here
	ego_slot_container.move_child(from, to.unique_id)
	
	var counter: int = 0
	for slot in ego_slot_container.get_children():
		if slot.unique_id != counter:
			slot.unique_id = counter
		
		counter += 1
	
