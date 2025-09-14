extends Node

signal MiningDrone_added(MiningDrone)

# Called in ShopSystem.gd
func spawn_mining_drone() -> void:
	var MiningDrone_scene: PackedScene = load(ScenePaths.DRONE_SCENES.mining_drone)
	var MiningDrone = MiningDrone_scene.instantiate()
	get_tree().get_current_scene().get_node("WorldRoot").add_child(MiningDrone)
	MiningDrone.position = Vector2(100, 200)
	emit_signal("MiningDrone_added", MiningDrone)
