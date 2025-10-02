extends Control

signal resume_requested
signal quit_to_main_menu_requested

func _ready():
	visible = false
	add_to_group("menu")
	print("Menu: _ready() called")
	
	# Connect button signals directly
	var resume_btn = get_node("MarginContainer/VBoxContainer/ResumeButton")
	var save_btn = get_node("MarginContainer/VBoxContainer/SaveButton")
	var load_btn = get_node("MarginContainer/VBoxContainer/LoadButton")
	var quit_btn = get_node("MarginContainer/VBoxContainer/QuitToMainMenuButton")
	
	print("Menu: Connecting button signals")
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
		print("Menu: Resume button connected")
	if save_btn:
		save_btn.pressed.connect(_on_save_pressed)
		print("Menu: Save button connected")
	if load_btn:
		load_btn.pressed.connect(_on_load_pressed)
		print("Menu: Load button connected")
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)
		print("Menu: Quit button connected")

func show_menu():
	visible = true

func hide_menu():
	visible = false

func toggle_menu():
	if visible:
		hide_menu()
	else:
		show_menu()

func _on_resume_pressed():
	hide_menu()
	resume_requested.emit()

func _on_save_pressed():
	print("Menu: Save button pressed")
	# Hide menu and trigger save functionality
	hide_menu()
	# Create and show save slot selector directly
	_show_save_slot_selector()

func _show_save_slot_selector():
	"""Show save slot selector for saving"""
	# Remove any existing slot selector first
	_remove_slot_selector()
	
	# Open save slot selector for saving
	var slot_selector = preload("res://scenes/ui/SaveSlotSelector.tscn").instantiate()
	
	# Add to appropriate container based on current scene
	if get_tree().current_scene.name == "MainMenu":
		# MainMenu scene has CanvasLayer
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		canvas_layer.add_child(slot_selector)
	else:
		# Game scenes have UIRoot
		var ui_root = get_tree().current_scene.get_node("UIRoot")
		ui_root.add_child(slot_selector)
	
	slot_selector.set_mode("save")
	
	# Connect signals directly to this Menu instance
	slot_selector.load_requested.connect(_on_save_requested)
	slot_selector.delete_requested.connect(_on_delete_requested)
	slot_selector.action_cancelled.connect(_on_action_cancelled)
	slot_selector.back_pressed.connect(_on_back_pressed)

func _on_save_requested(slot_number: int) -> void:
	"""Handle save request from slot selector"""
	print("Menu: save_requested signal received for slot ", slot_number)
	
	# Save to the selected slot
	Global.save_to_slot(slot_number)
	print("Menu: Game saved to slot ", slot_number)
	
	# Remove slot selector
	_remove_slot_selector()
	
	# Close any open menu instances (from in-game menu)
	var menu_nodes = get_tree().get_nodes_in_group("menu")
	print("Menu: Found ", menu_nodes.size(), " menu nodes")
	for menu in menu_nodes:
		if menu.has_method("hide_menu"):
			print("Menu: Hiding menu")
			menu.hide_menu()

func _on_delete_requested(slot_number: int) -> void:
	"""Handle delete request from slot selector"""
	# The SaveSlotManager already handles the delete confirmation and deletion
	# This function is here for completeness but doesn't need to do anything
	print("Delete requested for slot ", slot_number)

func _on_action_cancelled() -> void:
	"""Handle action cancellation from slot selector"""
	# The SaveSlotManager already handles the cancellation
	# This function is here for completeness but doesn't need to do anything
	print("Action cancelled")

func _on_back_pressed() -> void:
	"""Handle back button - remove slot selector"""
	print("Menu: Back button pressed, removing slot selector")
	_remove_slot_selector()

func _remove_slot_selector():
	"""Remove the save slot selector"""
	var slot_selector = null
	
	if get_tree().current_scene.name == "MainMenu":
		var canvas_layer = get_tree().current_scene.get_node_or_null("CanvasLayer")
		if canvas_layer:
			slot_selector = canvas_layer.get_node_or_null("SaveSlotSelector")
			if slot_selector:
				print("Menu: Removing SaveSlotSelector from MainMenu")
				slot_selector.queue_free()
			else:
				print("Menu: SaveSlotSelector not found in MainMenu CanvasLayer")
		else:
			print("Menu: CanvasLayer not found in MainMenu")
	else:
		var ui_root = get_tree().current_scene.get_node_or_null("UIRoot")
		if ui_root:
			slot_selector = ui_root.get_node_or_null("SaveSlotSelector")
			if slot_selector:
				print("Menu: Removing SaveSlotSelector from UIRoot")
				slot_selector.queue_free()
			else:
				print("Menu: SaveSlotSelector not found in UIRoot")
		else:
			print("Menu: UIRoot not found in current scene")
	
	# Fallback: search for SaveSlotSelector anywhere in the scene
	if not slot_selector:
		slot_selector = get_tree().current_scene.find_child("SaveSlotSelector", true, false)
		if slot_selector:
			print("Menu: Found SaveSlotSelector via fallback search, removing it")
			slot_selector.queue_free()
		else:
			print("Menu: SaveSlotSelector not found anywhere in scene")

func _on_load_pressed():
	print("Menu: Load button pressed")
	# Hide menu and trigger load functionality
	hide_menu()
	# Create and show load slot selector directly
	_show_load_slot_selector()

func _show_load_slot_selector():
	"""Show load slot selector for loading"""
	# Remove any existing slot selector first
	_remove_slot_selector()
	
	# Open save slot selector for loading
	var slot_selector = preload("res://scenes/ui/SaveSlotSelector.tscn").instantiate()
	
	# Add to appropriate container based on current scene
	if get_tree().current_scene.name == "MainMenu":
		# MainMenu scene has CanvasLayer
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		canvas_layer.add_child(slot_selector)
	else:
		# Game scenes have UIRoot
		var ui_root = get_tree().current_scene.get_node("UIRoot")
		ui_root.add_child(slot_selector)
	
	slot_selector.set_mode("load")
	
	# Connect signals directly to this Menu instance
	slot_selector.load_requested.connect(_on_load_requested)
	slot_selector.delete_requested.connect(_on_delete_requested)
	slot_selector.action_cancelled.connect(_on_action_cancelled)
	slot_selector.back_pressed.connect(_on_back_pressed)

func _on_load_requested(slot_number: int) -> void:
	"""Handle load request from slot selector"""
	print("Menu: load_requested signal received for slot ", slot_number)
	
	# Load from the selected slot
	Global.load_from_slot(slot_number)
	print("Menu: Game loaded from slot ", slot_number)
	
	# Remove slot selector
	_remove_slot_selector()
	
	# Always go to Camp.tscn when loading a game
	get_tree().change_scene_to_file("res://scenes/main/Camp.tscn")

func _on_quit_pressed():
	quit_to_main_menu_requested.emit()
