extends Button

func _ready():
	pressed.connect(_on_save_pressed)

func _on_save_pressed():
	# Hide any open menus before showing save slot selector
	_hide_menus()
	
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
	
	# Connect signals
	slot_selector.load_requested.connect(_on_save_requested)
	slot_selector.delete_requested.connect(_on_delete_requested)
	slot_selector.action_cancelled.connect(_on_action_cancelled)
	slot_selector.back_pressed.connect(_on_back_pressed)

func _on_save_requested(slot_number: int) -> void:
	"""Handle save request from slot selector"""
	print("SaveButton: save_requested signal received for slot ", slot_number)
	
	# Save to the selected slot
	Global.save_to_slot(slot_number)
	print("Game saved to slot ", slot_number)
	
	# Remove slot selector
	_remove_slot_selector()
	
	# Close any open menu instances (from in-game menu)
	var menu_nodes = get_tree().get_nodes_in_group("menu")
	print("SaveButton: Found ", menu_nodes.size(), " menu nodes")
	for menu in menu_nodes:
		if menu.has_method("hide_menu"):
			print("SaveButton: Hiding menu")
			menu.hide_menu()
	
	# Restore menus after closing save slot selector
	_restore_menus()

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
	print("SaveButton: Back button pressed, removing slot selector")
	_remove_slot_selector()
	
	# Restore menus after closing save slot selector
	_restore_menus()

func _remove_slot_selector() -> void:
	"""Helper function to remove the slot selector"""
	print("SaveButton: Current scene name: ", get_tree().current_scene.name)
	var slot_selector = null
	
	if get_tree().current_scene.name == "MainMenu":
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		slot_selector = canvas_layer.get_node("SaveSlotSelector")
		if slot_selector:
			print("SaveButton: Removing SaveSlotSelector from MainMenu")
			slot_selector.queue_free()
		else:
			print("SaveButton: SaveSlotSelector not found in MainMenu CanvasLayer")
	else:
		var ui_root = get_tree().current_scene.get_node("UIRoot")
		slot_selector = ui_root.get_node("SaveSlotSelector")
		if slot_selector:
			print("SaveButton: Removing SaveSlotSelector from UIRoot")
			slot_selector.queue_free()
		else:
			print("SaveButton: SaveSlotSelector not found in UIRoot")
	
	# Fallback: search for SaveSlotSelector anywhere in the scene
	if not slot_selector:
		slot_selector = get_tree().current_scene.find_child("SaveSlotSelector", true, false)
		if slot_selector:
			print("SaveButton: Found SaveSlotSelector via fallback search, removing it")
			slot_selector.queue_free()
		else:
			print("SaveButton: SaveSlotSelector not found anywhere in scene")

func _hide_menus() -> void:
	"""Hide any open menus"""
	# Hide Menu.tscn if it exists (from in-game menu)
	var menu_nodes = get_tree().get_nodes_in_group("menu")
	for menu in menu_nodes:
		if menu.has_method("hide_menu"):
			menu.hide_menu()
	
	# Hide MainMenu.tscn VBoxContainer if it's the current scene
	if get_tree().current_scene.name == "MainMenu":
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		var vbox = canvas_layer.get_node("VBoxContainer")
		if vbox:
			vbox.visible = false

func _restore_menus() -> void:
	"""Restore menus after closing save slot selector"""
	# Restore MainMenu.tscn VBoxContainer if it was hidden
	if get_tree().current_scene.name == "MainMenu":
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		var vbox = canvas_layer.get_node("VBoxContainer")
		if vbox:
			vbox.visible = true
