extends Control
class_name BuildingMenu

signal menu_closed
signal item_selected(item_id: String)
# signal purchase_requested(item_id: String)  # Reserved for future use

# Base UI references - to be overridden by subclasses
@onready var close_button: Button
@onready var title_label: Label
@onready var content_container: Control

# Menu state
var menu_visible: bool = false
var building_type: String = ""

func _ready():
	visible = false
	add_to_group("building_menu")
	
	# Connect close button - try different possible paths
	close_button = _find_close_button()
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Get title label - try different possible paths
	title_label = _find_title_label()
	
	# Get content container - try different possible paths
	content_container = _find_content_container()
	
	# Connect input handling
	set_process_input(true)

func _find_close_button() -> Button:
	"""Find the close button in the UI hierarchy"""
	# Try different possible paths for the close button
	var paths_to_try = [
		"CloseButton",
		"NinePatchRect/MarginContainer/VBoxContainer/CloseButton",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/HBoxContainer/CloseButton",
		"NinePatchRect/MarginContainer/CraftingMenuArea/CloseButton"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Button:
				print("BuildingMenu: Found close button at path: ", path)
				return node
	print("BuildingMenu: Warning - Close button not found!")
	return null

func _find_title_label() -> Label:
	"""Find the title label in the UI hierarchy"""
	# Try different possible paths for the title label
	var paths_to_try = [
		"TitleLabel",
		"BuildingTitle",
		"ShopTitle",
		"NinePatchRect/MarginContainer/VBoxContainer/BuildingTitle",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/ShopTitle",
		"NinePatchRect/MarginContainer/CraftingMenuArea/TitleLabel"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Label:
				return node
	return null

func _find_content_container() -> Control:
	"""Find the content container in the UI hierarchy"""
	# Try different possible paths for the content container
	var paths_to_try = [
		"ContentContainer",
		"NinePatchRect/MarginContainer/VBoxContainer/ContentContainer",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/MarginShopItemsArea/ContentContainer",
		"NinePatchRect/MarginContainer/CraftingMenuArea/ContentContainer"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Control:
				return node
	return null

func _input(event):
	if event.is_action_pressed("ui_cancel") and menu_visible:
		close_menu()

func show_menu(building: String = ""):
	"""Show the menu for a specific building type"""
	building_type = building
	menu_visible = true
	visible = true
	
	# Update title if we have a title label
	if title_label:
		title_label.text = _get_menu_title(building)
	
	# Let subclasses handle their specific setup
	_on_menu_shown(building)

func hide_menu():
	"""Hide the menu"""
	menu_visible = false
	visible = false
	_on_menu_hidden()

func close_menu():
	"""Close the menu and emit signal"""
	print("BuildingMenu: close_menu() called")
	hide_menu()
	menu_closed.emit()
	print("BuildingMenu: menu_closed signal emitted")

func _on_close_pressed():
	print("BuildingMenu: Close button pressed!")
	close_menu()

# Virtual methods to be overridden by subclasses
func _on_menu_shown(_building: String):
	"""Called when menu is shown - override in subclasses"""
	pass

func _on_menu_hidden():
	"""Called when menu is hidden - override in subclasses"""
	pass

func _get_menu_title(building: String) -> String:
	"""Get the title for the menu based on building type"""
	match building:
		"ConstructionShop":
			return "Construction Shop"
		"DroneShop":
			return "Drone Shop"
		"CookingStove":
			return "Cooking Stove"
		"ScrapShop":
			return "Scrap Shop"
		"Smelter":
			return "Smelter"
		_:
			return "Building Menu"

# Helper methods for subclasses
func _create_item_button(item_id: String, _item_data: Dictionary) -> Button:
	"""Create a button for an item - can be overridden by subclasses"""
	var button = Button.new()
	button.text = _format_item_name(item_id)
	button.custom_minimum_size = Vector2(120, 40)
	
	# Connect button press
	button.pressed.connect(_on_item_button_pressed.bind(item_id))
	
	return button

func _format_item_name(item_id: String) -> String:
	"""Format item ID into a readable name"""
	return item_id.replace("_", " ").capitalize()

func _on_item_button_pressed(item_id: String):
	"""Handle item button press - can be overridden by subclasses"""
	item_selected.emit(item_id)
