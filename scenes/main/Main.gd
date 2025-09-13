extends Node2D

func _ready() -> void:
	GameDB.load_all()
	EventBus.subscribe("hello", func(p): print("EventBus got:", p))
	EventBus.emit("hello", "Phase 0 OK")
