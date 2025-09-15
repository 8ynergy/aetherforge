extends Node2D

@onready var pause_menu: Control = preload("res://scenes/ui/PauseMenu.tscn").instantiate()

func _ready() -> void:
	GameDB.load_all()
	EventBus.subscribe("hello", func(p): print("EventBus got:", p))
	EventBus.emit("hello", "Phase 0 OK")

	# Create a separate CanvasLayer for pause menu to ensure it renders on top
	var pause_layer = CanvasLayer.new()
	pause_layer.layer = 1  # Higher layer than UIRoot (which is 0)
	add_child(pause_layer)
	pause_layer.add_child(pause_menu)
	pause_menu.quit_to_main_menu_requested.connect(_on_quit_to_main_menu)
	pause_menu.resume_requested.connect(_on_resume_requested)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_pause_menu()

func toggle_pause_menu():
	if get_tree().paused:
		pause_menu.hide_pause_menu()
	else:
		pause_menu.show_pause_menu()

func _on_resume_requested():
	pause_menu.hide_pause_menu()

func _on_quit_to_main_menu():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
