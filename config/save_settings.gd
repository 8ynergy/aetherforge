class_name SaveSettings
extends Resource

# Save slot configuration
const MAX_SAVE_SLOTS = 5
const SAVE_SLOT_PREFIX = "user://save_slot_"

# Save file paths
const SAVE_PATH = "user://savegame.json"

# Save data structure keys
const SAVE_KEYS = {
	"inventory": "inventory",
	"stacks": "stacks", 
	"used": "used",
	"capacity": "capacity",
	"credits": "credits",
	"drones": "drones",
	"stamina": "stamina",
	"metadata": "metadata",
	"game_data": "game_data"
}

# Metadata keys
const METADATA_KEYS = {
	"timestamp": "timestamp",
	"player_name": "player_name",
	"level": "level",
	"playtime": "playtime",
	"first_play_date": "first_play_date"
}

# Drone identification
const DRONE_NAME_PREFIX = "Drone"

# Helper function to get save slot path
static func get_slot_path(slot_number: int) -> String:
	return SAVE_SLOT_PREFIX + str(slot_number) + ".json"
