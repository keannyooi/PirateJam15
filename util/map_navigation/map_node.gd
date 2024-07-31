class_name MapNode
extends Button

enum NodeStatus {LOCKED, UNLOCKED, COMPLETED}

@export var previous_nodes: Array[MapNode]
@export var future_nodes: Array[MapNode]
@export var linked_scene: PackedScene

var node_id: int = 0
var status: NodeStatus = NodeStatus.LOCKED


func _ready() -> void:
	if not linked_scene:
		push_error("ERROR: linked scene not found")
	

func update_status(new_status: NodeStatus) -> void:
	status = new_status
	
	match new_status:
		NodeStatus.LOCKED:
			self.disabled = true
			self.text = "X"
		NodeStatus.UNLOCKED:
			self.disabled = false
		NodeStatus.COMPLETED:
			self.disabled = true
		_:
			push_error("ERROR: invalid node status specified")
 
