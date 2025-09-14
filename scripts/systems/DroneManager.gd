extends Node

signal MiningDrone_added(MiningDrone)

# Called in ShopSystem.gd
func spawn_mining_drone() -> void:
	var MiningDrone_scene: PackedScene = load(ScenePaths.DRONE_SCENES.mining_drone)
	var MiningDrone = MiningDrone_scene.instantiate()
	
	# Name the drone so it can be counted properly
	MiningDrone.name = "Drone_" + str(get_tree().get_nodes_in_group("drones").size())
	MiningDrone.add_to_group("drones")
	
	get_tree().get_current_scene().get_node("WorldRoot").add_child(MiningDrone)
	MiningDrone.position = Vector2(100, 200)
	emit_signal("MiningDrone_added", MiningDrone)
