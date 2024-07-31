class_name MapNavigation
extends CanvasLayer

@export var floor_number: int = 1
@export var boss_node: MapNode
@export var end_node: MapNode
@export var root_node: MapNode

@onready var map_nodes: Control = $MapNodes

var current_node: MapNode

var node_list: Array = [] #Initialize with root nodenodes
var visited_node_list: Array = [] #Initialize with root node
	
func _ready() -> void:
	# assign unique ids to nodes
	current_node = root_node
	node_list.push_back(root_node)
	while not node_list.is_empty(): #Go through every existing node
		var node = node_list.pop_front() #remove current node from the list
		visited_node_list.push_back(node) #Add current node to visited list
		for new_node in node.future_nodes: #Go through every future node the current node coud connect to
			if (not visited_node_list.has(new_node)) and (not node_list.has(new_node)): #If that node is not in our list, add it.
				node_list.push_back(new_node)
		node.pressed.connect(select_node.bind(node)) #connect node to linked scene
		node.update_status(MapNode.NodeStatus.LOCKED) #default nodes to LOCKED
	
	if PlayerData.completed_nodes.is_empty():
		root_node.update_status(MapNode.NodeStatus.UNLOCKED)
		PlayerData.completed_nodes.push_back(root_node)
	
	for node in PlayerData.completed_nodes: #All nodes that have been visited are completed
		node.update_status(MapNode.NodeStatus.COMPLETED)
		
	current_node = PlayerData.completed_nodes.back()
	for node in current_node.future_nodes: #Unlock nodes that can be visited
		node.update_status(MapNode.NodeStatus.UNLOCKED)
	
	#var i = 1"indices/0"
	#for node in map_nodes.get_children():
		#node.node_id = i
		#
		#node.pressed.connect(select_node.bind(node.linked_scene))
		#
		#if PlayerData.completed_nodes.has(node.node_id):
			#node.update_status(MapNode.NodeStatus.COMPLETED)
		#elif node.previous_nodes.any(func (n): 
			#return n.status == MapNode.NodeStatus.COMPLETED) \
		#or node.node_id == 1:
			#node.update_status(MapNode.NodeStatus.UNLOCKED)
		#else:
			#node.update_status(MapNode.NodeStatus.LOCKED)
		#
		#i += 1
	

func select_node(node: MapNode) -> void:
	for future_node in current_node.future_nodes: #Lock all node paths that have been ignored
		future_node.update_status(MapNode.NodeStatus.LOCKED)
	# Update Current Node
	current_node = node
	var new_event = node.linked_scene.instantiate()
	new_event.parent = %Event
	new_event.next_event = %MapNodes
	%Event.add_child(new_event)
	%MapNodes.hide()
	

func update_node_status():
	if PlayerData.completed_nodes.is_empty():
		root_node.update_status(MapNode.NodeStatus.UNLOCKED)
		PlayerData.completed_nodes.push_back(root_node)
		
	for node in PlayerData.completed_nodes: #All nodes that have been visited are completed
		node.update_status(MapNode.NodeStatus.COMPLETED)
		
	current_node = PlayerData.completed_nodes.back()
	for node in current_node.future_nodes: #Unlock nodes that can be visited
		node.update_status(MapNode.NodeStatus.UNLOCKED)

func _on_event_child_exiting_tree(node):
	PlayerData.completed_nodes.push_back(current_node)
	update_node_status()
	%MapNodes.show()
