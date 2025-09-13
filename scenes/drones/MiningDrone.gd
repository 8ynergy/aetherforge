extends Node2D

@export var cycle_time := 1.5

var t := 0.0
var active := true

func _process(delta: float) -> void:
	if not active: return
	t += delta
	if t >= cycle_time:
		t = 0.0
		_mine_once()

func _mine_once() -> void:
	# Simplest: just add 1 stone each cycle
	var inv = get_tree().get_first_node_in_group("inventory")
	if inv:
		inv.add("stone", 1)
