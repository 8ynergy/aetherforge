extends Button

func _pressed() -> void:
	# Hide MainMenu background when opening slot selector
	_hide_mainmenu_background()
	
	# Open save slot selector for new game
	var slot_selector = preload("res://scenes/ui/SaveSlotSelector.tscn").instantiate()
	# Add to CanvasLayer instead of directly to the scene
	var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	canvas_layer.add_child(slot_selector)
	slot_selector.set_mode("new_game")
	
	# Connect signals
	slot_selector.slot_selected.connect(_on_slot_selected)
	slot_selector.back_pressed.connect(_on_back_pressed)

func _on_slot_selected(slot_number: int) -> void:
	"""Handle slot selection for new game"""
	# Set the current save slot
	Global.set_current_slot(slot_number)
	
	# Reset game data for new game
	Global.reset_game_data()
	
	# Start new game
	get_tree().change_scene_to_file("res://scenes/main/Camp.tscn")

func _on_back_pressed() -> void:
	"""Handle back button - remove slot selector"""
	var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	var slot_selector = canvas_layer.get_node("SaveSlotSelector")
	if slot_selector:
		slot_selector.queue_free()
	
	# Restore MainMenu background
	_restore_mainmenu_background()

func _hide_mainmenu_background() -> void:
	"""Hide MainMenu background elements"""
	# Hide the main menu container
	var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	var vbox = canvas_layer.get_node("VBoxContainer")
	if vbox:
		vbox.visible = false

func _restore_mainmenu_background() -> void:
	"""Restore MainMenu background elements"""
	# Show the main menu container
	var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
	var vbox = canvas_layer.get_node("VBoxContainer")
	if vbox:
		vbox.visible = true
