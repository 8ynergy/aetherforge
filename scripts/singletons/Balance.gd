extends Node

# Save settings
const SAVE_DEFAULTS = {
	"inventory_capacity": 200,
	"inventory_used": 0,
	"inventory_credits": 0
}

# Inventory settings
const INVENTORY_CAPACITY = 200
const STARTING_CREDITS = 100

# Combat settings
const CLICK_BASE_DAMAGE = 1.0

# Resource node settings
# Order: Diamond, Titanium, Platinum, Gold, Silver, Iron, Copper, Tin, Coal, Rock
# Each is 2 HP more than the next in the sequence (reversed)
const RESOURCE_NODE_SETTINGS = {
	"diamond": {"max_hp": 20, "resource_amount": 1},
	"titanium": {"max_hp": 18, "resource_amount": 1},
	"platinum": {"max_hp": 16, "resource_amount": 1},
	"gold": {"max_hp": 14, "resource_amount": 1},	
	"silver": {"max_hp": 12, "resource_amount": 1},
	"iron": {"max_hp": 10, "resource_amount": 1},	
	"copper": {"max_hp": 8, "resource_amount": 1},
	"tin": {"max_hp": 6, "resource_amount": 1},
	"coal": {"max_hp": 4, "resource_amount": 1},
	"stone": {"max_hp": 2, "resource_amount": 1}
}

# Smelting settings
const SMELT_RECIPES = {
	"stone": {"cost": 10, "out": "stone_bar", "out_qty": 1, "time": 2.0}
}

func click_damage() -> float:
	return CLICK_BASE_DAMAGE

func get_resource_node_settings(resource_type: String) -> Dictionary:
	return RESOURCE_NODE_SETTINGS.get(resource_type, {"max_hp": 1, "resource_amount": 1})

func get_save_defaults() -> Dictionary:
	return SAVE_DEFAULTS

func get_smelt_recipes() -> Dictionary:
	return SMELT_RECIPES

func get_starting_credits() -> int:
	return STARTING_CREDITS

func get_inventory_capacity() -> int:
	return INVENTORY_CAPACITY
