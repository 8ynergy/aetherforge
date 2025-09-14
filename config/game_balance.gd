class_name GameBalance
extends Resource

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
const ROCK_MAX_HP = 2

# Smelting settings
const SMELT_RECIPES = {
	"stone": {"cost": 10, "out": "stone_bar", "out_qty": 1, "time": 2.0}
}
