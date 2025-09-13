extends Node

signal tick(delta: float)

func _process(delta: float) -> void:
	emit_signal("tick", delta)
