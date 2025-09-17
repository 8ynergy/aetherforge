extends Node2D

@onready var menu: Control = preload("res://scenes/ui/Menu.tscn").instantiate()

func _ready() -> void:
	GameDB.load_all()
	EventBus.subscribe("hello", func(p): print("EventBus got:", p))
	EventBus.emit("hello", "Phase 0 OK")

	# Create a separate CanvasLayer for menu to ensure it renders on top
	var menu_layer = CanvasLayer.new()
	menu_layer.layer = 1  # Higher layer than UIRoot (which is 0)
	add_child(menu_layer)
	menu_layer.add_child(menu)
	menu.quit_to_main_menu_requested.connect(_on_quit_to_main_menu)
	menu.resume_requested.connect(_on_resume_requested)

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		toggle_menu()

func toggle_menu():
	if get_tree().menu:
		menu.hide_menu()
	else:
		menu.show_menu()

func _on_resume_requested():
	menu.hide_menu()

func _on_quit_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")
