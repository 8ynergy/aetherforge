extends Button

func _ready():
	pressed.connect(_on_load_pressed)

func _on_load_pressed():
	# Hide any open menus before showing save slot selector
	_hide_menus()
	
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
	
	# Connect signals
	slot_selector.load_requested.connect(_on_load_requested)
	slot_selector.delete_requested.connect(_on_delete_requested)
	slot_selector.action_cancelled.connect(_on_action_cancelled)
	slot_selector.back_pressed.connect(_on_back_pressed)

func _on_load_requested(slot_number: int) -> void:
	"""Handle load request from slot selector"""
	# Load from the selected slot
	Global.load_from_slot(slot_number)
	print("Game loaded from slot ", slot_number)
	
	# Remove slot selector
	_remove_slot_selector()
	
	# Always go to Camp.tscn when loading a game
	get_tree().change_scene_to_file("res://scenes/main/Camp.tscn")

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
	_remove_slot_selector()
	
	# Restore menus after closing save slot selector
	_restore_menus()

func _remove_slot_selector() -> void:
	"""Helper function to remove the slot selector"""
	if get_tree().current_scene.name == "MainMenu":
		var canvas_layer = get_tree().current_scene.get_node("CanvasLayer")
		var slot_selector = canvas_layer.get_node("SaveSlotSelector")
		if slot_selector:
			slot_selector.queue_free()
	else:
		var ui_root = get_tree().current_scene.get_node("UIRoot")
		var slot_selector = ui_root.get_node("SaveSlotSelector")
		if slot_selector:
			slot_selector.queue_free()

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
