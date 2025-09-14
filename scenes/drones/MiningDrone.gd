extends Node2D

@export var cycle_time := 1.5
@export var mining_range := 100.0  # How far the drone can mine

var t := 0.0
var active := true
var target_node: ResourceNode = null

func _ready() -> void:
	# Ensure the drone starts mining when spawned
	active = true
	_find_nearest_resource_node()
	_connect_to_resource_nodes()

func _process(delta: float) -> void:
	if not active: return
	t += delta
	if t >= cycle_time:
		t = 0.0
		_mine_once()

func _find_nearest_resource_node() -> void:
	# Find the nearest resource node to mine (any node with "Node" in the name)
	var world = get_tree().get_current_scene().get_node("WorldRoot")
	var resource_nodes = _find_all_resource_nodes(world)
	
	var nearest_node = null
	var nearest_distance = mining_range
	
	for node in resource_nodes:
		var distance = global_position.distance_to(node.global_position)
		if distance < nearest_distance:
			nearest_node = node
			nearest_distance = distance
	
	target_node = nearest_node
	if target_node != null:
		print("Drone: Found target node: ", target_node.name)
	else:
		print("Drone: Found target node: None")

func _mine_once() -> void:
	# Check if we have a valid target
	if not target_node or not is_instance_valid(target_node):
		_find_nearest_resource_node()
		return
	
	# Check if target is still in range
	if global_position.distance_to(target_node.global_position) > mining_range:
		_find_nearest_resource_node()
		return
	
	# Mine the resource node
	if target_node.has_method("_hit"):
		target_node._hit(1.0)
		print("Drone: Mined ", target_node.resource_type, " from ", target_node.name)
	else:
		print("Drone: Target node doesn't have _hit method")

func _on_resource_depleted(_node: ResourceNode, _resource_type: String, _amount: int) -> void:
	# Called when a resource node is depleted, find a new target
	print("Drone: Resource node depleted, finding new target")
	_find_nearest_resource_node()

func _find_all_resource_nodes(parent: Node) -> Array:
	# Recursively find all resource nodes in the scene tree
	var resource_nodes = []
	
	for child in parent.get_children():
		if child.name.contains("Node") and child is ResourceNode:
			resource_nodes.append(child)
		# Recursively search children
		resource_nodes.append_array(_find_all_resource_nodes(child))
	
	return resource_nodes

func _connect_to_resource_nodes() -> void:
	# Connect to resource depletion signals
	var world = get_tree().get_current_scene().get_node("WorldRoot")
	var resource_nodes = _find_all_resource_nodes(world)
	
	for node in resource_nodes:
		if node.has_signal("resource_depleted"):
			node.connect("resource_depleted", Callable(self, "_on_resource_depleted"))
