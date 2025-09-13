extends Node

signal MiningDrone_added(MiningDrone)

func spawn_MiningDrone() -> void:
	var MiningDrone_scene: PackedScene = load("res://scenes/drones/MiningDrone.tscn")
	var MiningDrone = MiningDrone_scene.instantiate()
	get_tree().get_current_scene().get_node("WorldRoot").add_child(MiningDrone)
	MiningDrone.position = Vector2(100, 200)
	emit_signal("MiningDrone_added", MiningDrone)
