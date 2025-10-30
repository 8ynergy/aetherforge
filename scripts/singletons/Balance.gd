extends Node

# Save settings
const SAVE_DEFAULTS = {
	"inventory_capacity": 200,
	"inventory_used": 0,
	"inventory_credits": 100
}

# Inventory settings
const INVENTORY_CAPACITY = 200
const STARTING_CREDITS = 100

# Combat settings
const CLICK_BASE_DAMAGE = 1.0

# Stamina settings
const MAX_STAMINA = 1000
const MINING_STAMINA_COST = 100
const STAMINA_RESTORE_RATE = 10.0  # stamina per second

# Visual effects settings
const HIT_EFFECT_SETTINGS = {
	"brightness_start": 15.0,	# Initial brightness for white flash
	"brightness_end": 1.0,	   # Final brightness (normal)
	"duration_base": 0.25		# Base duration in seconds
}

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

# Smelter settings
const SMELT_RECIPES = {
	"stone": {"cost": 10, "out": "stone_bar", "out_qty": 1, "time": 2.0}
}

# Resource spawning settings
const RESOURCE_SPAWN_SETTINGS = {
	"base_spawn_count": 20,
	"spawn_interval": 10.0,
	"grid_size": 64,
	"spawn_margin": 100
}

# Cave level resource configurations
# Each level defines the ratio of different resources that can spawn
const CAVE_LEVEL_RESOURCES = {
	1: {"stone": 5, "copper": 1},  # 5:1 ratio for level 1
	2: {"stone": 4, "copper": 2, "iron": 1},  # More variety in level 2
	3: {"stone": 3, "copper": 3, "iron": 2, "silver": 1}  # Even more variety in level 3
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

func get_hit_effect_duration(speed_multiplier: float = 1.0) -> float:
	"""Get hit effect duration, optionally modified by speed multiplier"""
	return HIT_EFFECT_SETTINGS.duration_base / speed_multiplier

func get_hit_effect_settings() -> Dictionary:
	"""Get all hit effect settings"""
	return HIT_EFFECT_SETTINGS

func get_resource_spawn_settings() -> Dictionary:
	"""Get resource spawning configuration"""
	return RESOURCE_SPAWN_SETTINGS

func get_cave_level_resources() -> Dictionary:
	"""Get cave level resource configurations"""
	return CAVE_LEVEL_RESOURCES

# Stamina-related functions
func get_max_stamina() -> int:
	"""Get maximum stamina value"""
	return MAX_STAMINA

func get_mining_stamina_cost() -> int:
	"""Get stamina cost for mining one resource node"""
	return MINING_STAMINA_COST

func get_stamina_restore_rate() -> float:
	"""Get stamina restoration rate per second"""
	return STAMINA_RESTORE_RATE
