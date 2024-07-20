extends Node2D
class_name Event

@export var EVENT_ID : String

@onready var narration_system = $NarrationSystem


func _ready():
	narration_system.start_narration("opening")

func _process(delta):
	pass
