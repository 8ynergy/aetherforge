extends Control

# UI references
@onready var credits_label: Label = $MarginTop/HUDTopLeft/NinePatchRect/MarginContainer/CreditsLabel
@onready var resources_btn: MenuButton = $MarginBottom/HUDBottom/ResourcesButton
@onready var smelt_btn: Button = $SmeltButton
@onready var buy_drone_btn: Button = $BuyDroneButton
@onready var menu_btn: Button = $MarginBottom/HUDBottom/MenuButton

var menu_scene: PackedScene = preload("res://scenes/ui/Menu.tscn")
var menu_instance: Control = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks to pass through to world objects
	
	
	# Connect button signals
	if smelt_btn:
		smelt_btn.pressed.connect(_on_smelt_pressed)
	if buy_drone_btn:
		buy_drone_btn.pressed.connect(_on_buy_drone_pressed)
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
	if resources_btn:
		resources_btn.about_to_popup.connect(_on_resources_menu_about_to_popup)
		# Also connect to the popup's about_to_popup signal for positioning
		var popup = resources_btn.get_popup()
		popup.about_to_popup.connect(_on_resources_popup_positioning)
	
	# Connect to Inventory signals with a delay to ensure it's ready
	await get_tree().process_frame
	
	if Inventory:
		Inventory.inventory_changed.connect(_on_inventory_changed)
	
	_refresh_all()

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_on_menu_pressed()

func _on_menu_pressed():
	if not menu_instance:
		# Create menu instance if it doesn't exist
		menu_instance = menu_scene.instantiate()
		
		# Add to a high layer to ensure it renders on top
		var menu_layer = CanvasLayer.new()
		menu_layer.layer = 1
		get_tree().current_scene.add_child(menu_layer)
		menu_layer.add_child(menu_instance)
		
		# Connect menu signals
		menu_instance.quit_to_main_menu_requested.connect(_on_menu_quit_requested)
		menu_instance.resume_requested.connect(_on_menu_resume_requested)
	
	# Toggle the menu
	menu_instance.toggle_menu()

func _on_menu_quit_requested():
	# Handle quit to main menu
	get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")

func _on_menu_resume_requested():
	# Menu will handle hiding itself, no action needed here
	pass

func _on_smelt_pressed():
	var smelter = get_tree().root.find_child("Smelter", true, false)
	if smelter and smelter.enqueue("stone", 10):
		print("Enqueued 10 stone")
	else:
		print("Failed to enqueue")

func _on_buy_drone_pressed():
	var shop = get_tree().root.find_child("ShopSystem", true, false)
	if shop:
		shop.buy("mining_drone_mk1")

func _on_inventory_changed(_id: String, _qty: int) -> void:
	_refresh_all()

func _refresh_all() -> void:
	if Inventory and credits_label:
		var credits = Inventory.get_credits()
		credits_label.text = "Credits: %d" % credits
		

func _on_resources_menu_about_to_popup():
	if not Inventory:
		return
	
	 # Clear existing items in the popup
	var popup = resources_btn.get_popup()
	popup.clear()
	
	# Get all discovered resources
	var discovered = Inventory.get_discovered_resources()
	
	# Filter to only show actual resources (not credits)
	var resource_types = ItemDatabase.RESOURCE_TYPES.keys()
	var display_resources = []
	
	for resource_id in discovered:
		if resource_id in resource_types:
				display_resources.append(resource_id)
	
	# Sort resources for consistent display
	display_resources.sort()
	
	# Add each resource as a menu item
	for resource_id in display_resources:
		var qty = Inventory.get_qty(resource_id)
		var display_name = resource_id.replace("_", " ").capitalize()
		popup.add_item("%s: %d" % [display_name, qty])

func _on_resources_popup_positioning():
	# Position popup to the right of button + 4px margin
	var button_rect = resources_btn.get_global_rect()
	var popup = resources_btn.get_popup()
	popup.position = Vector2(button_rect.position.x + button_rect.size.x + 4, button_rect.position.y)
		
func _format_resource_name(resource_id: String) -> String:
	# Convert snake_case to Title Case
	var words = resource_id.split("_")
	var formatted = ""
	for word in words:
		formatted += word.capitalize() + " "
	return formatted.strip_edges()
