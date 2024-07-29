class_name MapNavigation
extends CanvasLayer

@export var root_node: MapNode

@onready var map_nodes: Control = $MapNodes


func _ready() -> void:
	# assign unique ids to nodes
	var i = 1
	for node in map_nodes.get_children():
		node.node_id = i
		
		node.pressed.connect(select_node.bind(node.linked_scene))
		
		if PlayerData.completed_nodes.has(node.node_id):
			node.update_status(MapNode.NodeStatus.COMPLETED)
		elif node.previous_nodes.any(func (n): 
			return n.status == MapNode.NodeStatus.COMPLETED) \
		or node.node_id == 1:
			node.update_status(MapNode.NodeStatus.UNLOCKED)
		else:
			node.update_status(MapNode.NodeStatus.LOCKED)
		
		i += 1
	

func select_node(linked_scene: PackedScene) -> void:
	pass
	
