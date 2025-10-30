extends "res://scripts/ui/BuildingMenu.gd"
class_name CraftingMenu

# Crafting-specific UI references
@onready var recipes_container: VBoxContainer
@onready var materials_display: VBoxContainer
@onready var recipe_template: Panel

# Crafting data
var available_recipes: Array = []
var crafting_type: String = ""

# Timer display
var timer_display: VBoxContainer
var smelter_system: Node

# Font size configuration
const MATERIALS_FONT_SIZE = 12
const TIMER_FONT_SIZE = 12
const PROGRESS_TIME_FONT_SIZE = 11
const PROGRESS_BAR_FONT_SIZE = 11

func _ready():
	super._ready()
	
	# Get crafting-specific UI elements
	recipes_container = _find_recipes_container()
	materials_display = _find_materials_display()
	recipe_template = _find_recipe_template()
	
	# Connect to inventory changes
	if Inventory:
		Inventory.inventory_changed.connect(_on_inventory_changed)

func _on_menu_shown(building: String):
	"""Setup crafting when menu is shown"""
	crafting_type = building
	available_recipes = _get_available_recipes_for_building(building)
	
	# Hide the template since it's now visible in the scene
	if recipe_template:
		recipe_template.visible = false
	
	# Set 50/50 split for HSplitContainer
	_set_hsplit_50_50()
	
	# Find smelter system for timer updates
	_find_smelter_system()
	
	_display_recipes()
	_update_materials_display()
	
	# Create timer display after materials display is set up
	_create_timer_display()
	_update_timer_display()

func _on_menu_hidden():
	"""Cleanup when menu is hidden"""
	pass

func _get_available_recipes_for_building(building: String) -> Array:
	"""Get available recipes for a specific building type"""
	match building:
		"Smelter":
			return ItemDatabase.SMELTER_RECIPES
		"CookingStove":
			return ItemDatabase.COOKING_RECIPES
		"ConstructionShop":
			return ItemDatabase.CONSTRUCTION_RECIPES
		_:
			return []

func _display_recipes():
	"""Display all available recipes"""
	if not recipes_container:
		return
	
	# Clear existing recipes
	for child in recipes_container.get_children():
		child.queue_free()
	
	# Add each recipe
	for recipe in available_recipes:
		var recipe_panel = _create_recipe_panel(recipe)
		recipes_container.add_child(recipe_panel)

func _create_recipe_panel(recipe: Dictionary) -> Panel:
	"""Create a panel for a recipe using the template"""
	if not recipe_template:
		print("CraftingMenu: Recipe template not found!")
		return null
	
	# Duplicate the template
	var panel = recipe_template.duplicate()
	panel.visible = true
	
	# Get the child elements
	var recipe_vbox = panel.get_node("RecipeVBox")
	var recipe_title_label = recipe_vbox.get_node("RecipeTitle")
	var materials_label = recipe_vbox.get_node("MaterialsLabel")
	var craft_button = recipe_vbox.get_node("CraftButton")
	
	# Set recipe title - show ??? if output item not discovered
	var output_id = recipe.get("output", "")
	var output_display_name = _get_output_display_name(output_id)
	recipe_title_label.text = output_display_name
	
	# Set materials text
	var materials_text = _format_materials_required(recipe.get("materials", {}))
	materials_label.text = materials_text
	
	# Configure craft button
	craft_button.text = "Craft"
	
	# Check if player has required materials
	var can_craft = _can_craft_recipe(recipe)
	craft_button.disabled = not can_craft
	
	if not can_craft:
		craft_button.modulate = Color(0.5, 0.5, 0.5, 1.0)
	else:
		craft_button.modulate = Color.WHITE
	
	# Connect button press
	# Clear any existing connections
	if craft_button.pressed.is_connected(_on_craft_pressed):
		craft_button.pressed.disconnect(_on_craft_pressed)
	craft_button.pressed.connect(_on_craft_pressed.bind(recipe))
	
	return panel

func _format_materials_required(materials: Dictionary) -> String:
	"""Format materials required for display"""
	if materials.is_empty():
		return "No materials required"
	
	var material_strings = []
	for material_id in materials.keys():
		var required_qty = materials[material_id]
		var available_qty = Inventory.get_qty(material_id) if Inventory else 0
		
		# Show ??? if player doesn't have enough materials OR hasn't discovered the material
		if available_qty < required_qty or not Inventory.is_resource_discovered(material_id):
			material_strings.append("???: ???")
		else:
			# Player has enough materials, show the actual material name and status
			var display_name = _format_item_name(material_id)
			var status = "✓" if available_qty >= required_qty else "✗"
			material_strings.append("%s: %d/%d %s" % [display_name, available_qty, required_qty, status])
	
	return "Materials: " + ", ".join(material_strings)

func _can_craft_recipe(recipe: Dictionary) -> bool:
	"""Check if player can craft this recipe"""
	if not Inventory:
		return false
	
	var materials = recipe.get("materials", {})
	for material_id in materials.keys():
		var required_qty = materials[material_id]
		var available_qty = Inventory.get_qty(material_id)
		
		# Player must have discovered the material and have enough
		if not Inventory.is_resource_discovered(material_id) or available_qty < required_qty:
			return false
	
	return true

func _on_craft_pressed(recipe: Dictionary):
	"""Handle craft button press"""
	if not _can_craft_recipe(recipe):
		print("Cannot craft recipe - insufficient materials")
		return
	
	# For Smelter, use the existing SmelterSystem for timed crafting
	if crafting_type == "Smelter":
		_handle_smelter_crafting(recipe)
	else:
		# For other buildings, do instant crafting
		_handle_instant_crafting(recipe)

func _handle_smelter_crafting(recipe: Dictionary):
	"""Handle smelter crafting with timing"""
	# Use the already found smelter system
	if smelter_system:
		# Use the smelter system for timed crafting
		var materials = recipe.get("materials", {})
		for material_id in materials.keys():
			var required_qty = materials[material_id]
			if smelter_system.has_method("enqueue"):
				smelter_system.enqueue(material_id, required_qty)
				print("Queued %d x %s for smelting" % [required_qty, material_id])
		
		# Connect to smelter completion signal
		if not smelter_system.smelt_complete.is_connected(_on_smelt_complete):
			smelter_system.smelt_complete.connect(_on_smelt_complete)
	else:
		print("Warning: SmelterSystem not found, falling back to instant crafting")
		_handle_instant_crafting(recipe)

func _handle_instant_crafting(recipe: Dictionary):
	"""Handle instant crafting for non-smelter buildings"""
	# Deduct materials
	var materials = recipe.get("materials", {})
	for material_id in materials.keys():
		var required_qty = materials[material_id]
		Inventory.add_to_inventory(material_id, -required_qty)
	
	# Add output item
	var output_id = recipe.get("output", "")
	var output_qty = recipe.get("output_qty", 1)
	Inventory.add_to_inventory(output_id, output_qty)
	
	print("Crafted %d x %s" % [output_qty, output_id])
	
	# Refresh display
	_display_recipes()
	_update_materials_display()

func _on_smelt_complete(item: String, qty: int):
	"""Handle smelter completion"""
	print("Smelter completed: %d x %s" % [qty, item])
	# Only update materials and timer, don't refresh recipes
	_update_materials_display()
	_update_timer_display()

func _create_timer_display():
	"""Create timer display in materials section"""
	if not materials_display:
		print("CraftingMenu: materials_display is null, cannot create timer display")
		return
	
	print("CraftingMenu: Creating timer display")
	
	# Create a separate container for timer that won't affect the split
	var timer_container = VBoxContainer.new()
	timer_container.name = "TimerContainer"
	timer_container.custom_minimum_size.y = 100  # Fixed height to prevent layout issues
	
	# Create timer section
	var timer_label = Label.new()
	timer_label.text = "Crafting Progress:"
	timer_label.add_theme_font_size_override("font_size", TIMER_FONT_SIZE)
	timer_container.add_child(timer_label)
	
	# Create container for timer items
	timer_display = VBoxContainer.new()
	timer_display.name = "TimerDisplay"
	timer_container.add_child(timer_display)
	
	# Add timer container to materials display
	materials_display.add_child(timer_container)
	
	print("CraftingMenu: Timer display created successfully")

func _find_smelter_system():
	"""Find the smelter system for timer updates"""
	smelter_system = get_tree().current_scene.get_node_or_null("SmelterSystem")
	if not smelter_system:
		# Try to find it in the smelter building
		var smelter_building = get_tree().current_scene.get_node_or_null("Smelter")
		if smelter_building:
			smelter_system = smelter_building.get_node_or_null("SmelterSystem")
	
	if smelter_system:
		print("CraftingMenu: Found smelter system")
	else:
		print("CraftingMenu: Warning - SmelterSystem not found")

func _update_timer_display():
	"""Update the timer display with current smelting progress"""
	if not timer_display:
		print("CraftingMenu: timer_display is null")
		return
	if not smelter_system:
		print("CraftingMenu: smelter_system is null")
		return
	
	print("CraftingMenu: Updating timer display")
	
	# Clear existing timer items
	for child in timer_display.get_children():
		child.queue_free()
	
	# Get current queue from smelter system
	var queue = []
	if smelter_system.has_method("get_queue"):
		queue = smelter_system.get_queue()
	elif smelter_system.get("queue") != null:
		queue = smelter_system.queue
	
	print("CraftingMenu: Queue has ", queue.size(), " items")
	
	for item in queue:
		_create_timer_item(item)

func _create_timer_item(queue_item: Dictionary):
	"""Create a timer display item for a queue item"""
	print("CraftingMenu: Creating timer item for ", queue_item.get("id", ""))
	
	var item_container = HBoxContainer.new()
	
	# Add spacer to push progress bar and time to the right
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_container.add_child(spacer)
	
	# Progress bar
	var progress_bar = ProgressBar.new()
	progress_bar.min_value = 0
	progress_bar.max_value = queue_item.get("time", 1.0)
	progress_bar.value = queue_item.get("t", 0.0)
	progress_bar.custom_minimum_size.x = 65
	progress_bar.add_theme_font_size_override("font_size", PROGRESS_BAR_FONT_SIZE)
	item_container.add_child(progress_bar)
	
	# Time remaining
	var time_label = Label.new()
	var remaining_time = queue_item.get("time", 1.0) - queue_item.get("t", 0.0)
	time_label.text = "%.1fs" % remaining_time
	time_label.custom_minimum_size.x = 60
	time_label.add_theme_font_size_override("font_size", PROGRESS_TIME_FONT_SIZE)
	item_container.add_child(time_label)
	
	timer_display.add_child(item_container)
	print("CraftingMenu: Timer item added to display")

func _process(_delta):
	"""Update timer display every frame"""
	if crafting_type == "Smelter" and timer_display and smelter_system:
		_update_timer_display()

func _update_materials_display():
	"""Update the materials display"""
	if not materials_display:
		return
	
	# Clear existing display
	for child in materials_display.get_children():
		child.queue_free()
	
	# Show discovered materials
	if Inventory:
		var discovered = Inventory.get_discovered_resources()
		for material_id in discovered:
			var qty = Inventory.get_qty(material_id)
			if qty > 0:
				var label = Label.new()
				label.text = "%s: %d" % [_format_item_name(material_id), qty]
				label.add_theme_font_size_override("font_size", MATERIALS_FONT_SIZE)
				materials_display.add_child(label)

func _on_inventory_changed(_id: String, _qty: int):
	"""Handle inventory changes"""
	# Only update materials and timer, don't refresh recipes unless needed
	_update_materials_display()
	if timer_display:
		_update_timer_display()

func _find_recipes_container() -> VBoxContainer:
	"""Find the recipes container in the UI hierarchy"""
	var paths_to_try = [
		"NinePatchRect/MarginContainer/CraftingMenuArea/ContentContainer/HSplitContainer/RecipesContainer/VBoxContainer"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is VBoxContainer:
				return node
	return null

func _find_materials_display() -> VBoxContainer:
	"""Find the materials display in the UI hierarchy"""
	var paths_to_try = [
		"NinePatchRect/MarginContainer/CraftingMenuArea/ContentContainer/HSplitContainer/MaterialsDisplay"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is VBoxContainer:
				return node
	return null

func _get_output_display_name(output_id: String) -> String:
	"""Get display name for output item, showing ??? if not discovered"""
	if not Inventory or not Inventory.is_resource_discovered(output_id):
		return "???"
	return _format_item_name(output_id)

func _set_hsplit_50_50():
	"""Set HSplitContainer to 50/50 split"""
	var hsplit_paths = [
		"NinePatchRect/MarginContainer/CraftingMenuArea/ContentContainer/HSplitContainer"
	]
	
	for path in hsplit_paths:
		if has_node(path):
			var hsplit = get_node(path)
			# Use a simple timer to ensure the container is ready
			get_tree().create_timer(0.1).timeout.connect(_apply_hsplit_50_50.bind(hsplit))
			return
	
	print("CraftingMenu: Warning - HSplitContainer not found!")

func _apply_hsplit_50_50(hsplit: HSplitContainer):
	"""Apply 50/50 split to HSplitContainer"""
	if hsplit and is_instance_valid(hsplit):
		# Set split to 50% of the container's width
		var split_offset = int(hsplit.size.x * 0.5)
		hsplit.split_offset = split_offset
		print("CraftingMenu: Set HSplitContainer split to 50/50 (size: ", hsplit.size.x, ", offset: ", split_offset, ")")
		
		# Ensure both children have equal size flags
		var recipes_child = hsplit.get_child(0)
		var materials_child = hsplit.get_child(1)
		
		if recipes_child and materials_child:
			# Set both containers to take equal space
			recipes_child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			materials_child.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			# Force immediate layout update
			hsplit.queue_redraw()

func _find_recipe_template() -> Panel:
	"""Find the recipe template in the UI hierarchy"""
	var paths_to_try = [
		"NinePatchRect/MarginContainer/CraftingMenuArea/ContentContainer/HSplitContainer/RecipesContainer/VBoxContainer/RecipeTemplate"
	]
	
	for path in paths_to_try:
		if has_node(path):
			var node = get_node(path)
			if node is Panel:
				return node
	return null
