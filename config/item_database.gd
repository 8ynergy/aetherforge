class_name ItemDatabase
extends Resource

const SHOP_OFFERS = {
	"mining_drone_mk1": {"cost": 50}
}

# Shop item pools for different shop types
const CONSTRUCTION_SHOP_ITEMS = [
	{"id": "wood_plank", "cost": 10},
	{"id": "metal_beam", "cost": 25},
	{"id": "concrete_block", "cost": 15},
	{"id": "glass_panel", "cost": 20},
	{"id": "insulation", "cost": 12},
	{"id": "wiring", "cost": 18}
]

const DRONE_SHOP_ITEMS = [
	{"id": "mining_drone_mk1", "cost": 50},
	{"id": "hauling_drone_mk1", "cost": 75},
	{"id": "construction_drone_mk1", "cost": 100},
	{"id": "drone_battery", "cost": 15},
	{"id": "drone_repair_kit", "cost": 30}
]

const COOKING_SHOP_ITEMS = [
	{"id": "cooked_meat", "cost": 8},
	{"id": "bread", "cost": 5},
	{"id": "soup", "cost": 12},
	{"id": "energy_bar", "cost": 10},
	{"id": "coffee", "cost": 6}
]

const SCRAP_SHOP_ITEMS = [
	{"id": "scrap_metal", "cost": 3},
	{"id": "old_wiring", "cost": 2},
	{"id": "broken_glass", "cost": 1},
	{"id": "rusty_bolts", "cost": 1},
	{"id": "plastic_parts", "cost": 2}
]

const SMELTER_SHOP_ITEMS = [
	{"id": "stone_bar", "cost": 20},
	{"id": "iron_bar", "cost": 35},
	{"id": "copper_bar", "cost": 30},
	{"id": "steel_bar", "cost": 50}
]

# Crafting recipes for different buildings
const SMELTER_RECIPES = [
	{
		"output": "stone_bar",
		"output_qty": 1,
		"materials": {"stone": 10}
	},
	{
		"output": "iron_bar", 
		"output_qty": 1,
		"materials": {"iron": 5}
	},
	{
		"output": "copper_bar",
		"output_qty": 1, 
		"materials": {"copper": 5}
	},
	{
		"output": "steel_bar",
		"output_qty": 1,
		"materials": {"iron": 3, "coal": 2}
	}
]

const COOKING_RECIPES = [
	{
		"output": "cooked_meat",
		"output_qty": 1,
		"materials": {"raw_meat": 1}
	},
	{
		"output": "bread",
		"output_qty": 2,
		"materials": {"flour": 2, "water": 1}
	},
	{
		"output": "soup",
		"output_qty": 1,
		"materials": {"vegetables": 2, "water": 1, "meat": 1}
	}
]

const CONSTRUCTION_RECIPES = [
	{
		"output": "wood_plank",
		"output_qty": 4,
		"materials": {"wood": 1}
	},
	{
		"output": "metal_beam",
		"output_qty": 1,
		"materials": {"iron_bar": 2}
	},
	{
		"output": "concrete_block",
		"output_qty": 1,
		"materials": {"stone": 3, "water": 1}
	}
]

const ITEM_IDS = {
	"stone": "stone",
	"stone_bar": "stone_bar", 
	"coal": "coal",
	"tin": "tin",
	"copper": "copper",
	"iron": "iron",
	"silver": "silver",
	"gold": "gold",
	"platinum": "platinum",
	"titanium": "titanium",
	"diamond": "diamond",
	"credits": "credits",
	# Additional items for shops and crafting
	"wood_plank": "wood_plank",
	"metal_beam": "metal_beam",
	"concrete_block": "concrete_block",
	"glass_panel": "glass_panel",
	"insulation": "insulation",
	"wiring": "wiring",
	"mining_drone_mk1": "mining_drone_mk1",
	"hauling_drone_mk1": "hauling_drone_mk1",
	"construction_drone_mk1": "construction_drone_mk1",
	"drone_battery": "drone_battery",
	"drone_repair_kit": "drone_repair_kit",
	"cooked_meat": "cooked_meat",
	"bread": "bread",
	"soup": "soup",
	"energy_bar": "energy_bar",
	"coffee": "coffee",
	"scrap_metal": "scrap_metal",
	"old_wiring": "old_wiring",
	"broken_glass": "broken_glass",
	"rusty_bolts": "rusty_bolts",
	"plastic_parts": "plastic_parts",
	"iron_bar": "iron_bar",
	"copper_bar": "copper_bar",
	"steel_bar": "steel_bar",
	"raw_meat": "raw_meat",
	"flour": "flour",
	"water": "water",
	"vegetables": "vegetables",
	"meat": "meat",
	"wood": "wood"
}

# Resource node types for easy reference
const RESOURCE_TYPES = {
	"stone": "stone",
	"coal": "coal",
	"tin": "tin",
	"copper": "copper",
	"iron": "iron",
	"silver": "silver",
	"gold": "gold",
	"platinum": "platinum",
	"titanium": "titanium",
	"diamond": "diamond"
}
