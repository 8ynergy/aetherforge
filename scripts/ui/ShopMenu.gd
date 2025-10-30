extends "res://scripts/ui/BuildingMenu.gd"
class_name ShopMenu

# Shop-specific UI references
@onready var items_container: VBoxContainer
@onready var refresh_button: Button
@onready var credits_display: Label

# Shop data
var available_items: Array = []
var current_shop_items: Array = []
var shop_type: String = ""

# Shop configuration
const ITEMS_PER_SHOP = 3
const REFRESH_COST = 5

func _ready():
	super._ready()
	
	# Get shop-specific UI elements
	items_container = _find_items_container()
	refresh_button = _find_refresh_button()
	credits_display = _find_credits_display()
	
	if refresh_button:
		refresh_button.pressed.connect(_on_refresh_pressed)
	
	# Connect to inventory changes
	if Inventory:
		Inventory.inventory_changed.connect(_on_inventory_changed)

func _on_menu_shown(building: String):
	"""Setup shop when menu is shown"""
	shop_type = building
	available_items = _get_available_items_for_shop(building)
	_refresh_shop_items()
	_update_credits_display()

func _on_menu_hidden():
	"""Cleanup when menu is hidden"""
	current_shop_items.clear()

func _get_available_items_for_shop(shop: String) -> Array:
	"""Get available items for a specific shop type"""
	match shop:
		"ConstructionShop":
			return ItemDatabase.CONSTRUCTION_SHOP_ITEMS
		"DroneShop":
			return ItemDatabase.DRONE_SHOP_ITEMS
		"CookingStove":
			return ItemDatabase.COOKING_SHOP_ITEMS
		"ScrapShop":
			return ItemDatabase.SCRAP_SHOP_ITEMS
		"Smelter":
			return ItemDatabase.SMELTER_SHOP_ITEMS
		_:
			return []

func _refresh_shop_items():
	"""Refresh the displayed shop items with random selection"""
	# Clear existing items
	if items_container:
		for child in items_container.get_children():
			child.queue_free()
	
	# Select random items
	current_shop_items = _select_random_items(available_items, ITEMS_PER_SHOP)
	
	# Create item buttons
	for item_data in current_shop_items:
		var item_button = _create_shop_item_button(item_data)
		if items_container:
			items_container.add_child(item_button)

func _select_random_items(items: Array, count: int) -> Array:
	"""Select random items from the available list"""
	if items.size() <= count:
		return items.duplicate()
	
	var selected = []
	var available = items.duplicate()
	
	for i in range(min(count, available.size())):
		var random_index = randi() % available.size()
		selected.append(available[random_index])
		available.remove_at(random_index)
	
	return selected

func _create_shop_item_button(item_data: Dictionary) -> Button:
	"""Create a shop item button with price and availability"""
	var button = Button.new()
	var item_id = item_data.get("id", "")
	var cost = item_data.get("cost", 0)
	var display_name = _format_item_name(item_id)
	
	# Check if player can afford it
	var can_afford = Inventory and Inventory.get_credits() >= cost
	
	button.text = "%s - %d Credits" % [display_name, cost]
	button.custom_minimum_size = Vector2(200, 50)
	
	# Disable button if can't afford
	if not can_afford:
		button.disabled = true
		button.modulate = Color(0.5, 0.5, 0.5, 1.0)
	
	# Connect button press
	button.pressed.connect(_on_shop_item_pressed.bind(item_id, cost))
	
	return button

func _on_shop_item_pressed(item_id: String, cost: int):
	"""Handle shop item purchase"""
	if not Inventory:
		return
	
	# Check if player can afford
	if Inventory.get_credits() < cost:
		print("Insufficient credits for %s" % item_id)
		return
	
	# Attempt purchase
	var shop_system = get_tree().root.find_child("ShopSystem", true, false)
	if shop_system:
		shop_system.buy(item_id)
		_update_credits_display()
		_refresh_shop_items()  # Refresh to update availability

func _on_refresh_pressed():
	"""Handle refresh button press"""
	if not Inventory:
		return
	
	# Check if player can afford refresh
	if Inventory.get_credits() < REFRESH_COST:
		print("Insufficient credits to refresh shop")
		return
	
	# Deduct refresh cost
	Inventory.spend_credits(REFRESH_COST)
	_refresh_shop_items()
	_update_credits_display()

func _update_credits_display():
	"""Update the credits display"""
	if credits_display and Inventory:
		var credits = Inventory.get_credits()
		credits_display.text = "Credits: %d" % credits

func _on_inventory_changed(_id: String, _qty: int):
	"""Handle inventory changes"""
	_update_credits_display()
	_refresh_shop_items()  # Refresh to update item availability

func _find_items_container() -> VBoxContainer:
	"""Find the items container in the UI hierarchy"""
	var paths_to_try = [
		"ContentContainer/ItemsContainer",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/MarginShopItemsArea/ContentContainer/ItemsContainer"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is VBoxContainer:
				return node
	return null

func _find_refresh_button() -> Button:
	"""Find the refresh button in the UI hierarchy"""
	var paths_to_try = [
		"ContentContainer/RefreshButton",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/HBoxContainer/RefreshButton"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Button:
				return node
	return null

func _find_credits_display() -> Label:
	"""Find the credits display in the UI hierarchy"""
	var paths_to_try = [
		"ContentContainer/CreditsDisplay",
		"NinePatchRect/MarginShopMenu/ShopMenuArea/CreditsDisplay"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Label:
				return node
	return null
