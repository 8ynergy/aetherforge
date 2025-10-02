extends Node

# Global script for game-wide functionality
# This handles auto-save on game exit and other global features

var _auto_save_timer: Timer

# Save system constants
const SAVE_PATH := SaveSettings.SAVE_PATH

# Current save slot tracking
var current_save_slot: int = 1
var game_start_time: float = 0.0
var session_start_time: float = 0.0

# Cave level system
var current_cave_level: int = 1

func _ready() -> void:
	# Connect to the notification system to detect when the game is closing
	# This ensures auto-save happens when the player closes the game
	
	_start_periodic_auto_save(300.0)  # Auto-save every 5 minutes (300 seconds)
	session_start_time = Time.get_unix_time_from_system()
	print("Global singleton initialized - periodic auto-save started")

func _notification(what: int) -> void:
	# Handle various notifications from the engine
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			# Game is being closed (X button, Alt+F4, etc.)
			_auto_save_on_exit()
			get_tree().quit()
		NOTIFICATION_CRASH:
			# Game crashed - try to save if possible
			_auto_save_on_exit()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			# Auto-save when Game loses focus
			_auto_save_on_exit()

func _auto_save_on_exit() -> void:
	# Attempt to save the game when exiting
	print("Auto-saving game on exit...")
	save_to_slot(current_save_slot)
	print("Game auto-saved successfully!")

# Optional: Add a manual auto-save function that can be called from anywhere
func manual_auto_save() -> void:
	"""Call this function to manually trigger an auto-save"""
	_auto_save_on_exit()

# Periodic auto-save functionality
func _start_periodic_auto_save(interval_seconds: float = 300.0) -> void:
	"""Start periodic auto-save every X seconds (default: 5 minutes)"""
	if _auto_save_timer:
		_auto_save_timer.queue_free()
	
	_auto_save_timer = Timer.new()
	_auto_save_timer.wait_time = interval_seconds
	_auto_save_timer.timeout.connect(_on_periodic_auto_save)
	_auto_save_timer.autostart = true
	add_child(_auto_save_timer)
	print("Periodic auto-save started (every ", interval_seconds, " seconds)")

func _on_periodic_auto_save() -> void:
	"""Called every X seconds for periodic auto-save"""
	print("Periodic auto-save triggered...")
	_auto_save_on_exit()

func _stop_periodic_auto_save() -> void:
	"""Stop periodic auto-save"""
	if _auto_save_timer:
		_auto_save_timer.queue_free()
		_auto_save_timer = null
		print("Periodic auto-save stopped")

# Save/Load System Functions
func save_game() -> void:
	"""Save the current game state to file"""
	# Safely get inventory data with fallbacks
	var inventory_data := {}
	if Inventory:
		inventory_data = {
			SaveSettings.SAVE_KEYS.stacks: Inventory.stacks if Inventory.stacks else {},
			SaveSettings.SAVE_KEYS.used: Inventory.used if Inventory.used else 0,
			SaveSettings.SAVE_KEYS.capacity: Inventory.capacity if Inventory.capacity else 0,
			SaveSettings.SAVE_KEYS.credits: Inventory.credits if Inventory.credits else 0
		}
	
	var data := {
		SaveSettings.SAVE_KEYS.inventory: inventory_data,
		SaveSettings.SAVE_KEYS.drones: _count_drones()
	}
	
	# Safely add discovered resources
	if Inventory and Inventory.has_method("get_discovered_resources"):
		data["discovered_resources"] = Inventory.get_discovered_resources()
	else:
		data["discovered_resources"] = []
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> void:
	"""Load the game state from file"""
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var txt = file.get_as_text()
	file.close()
	var data = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		return
	if data.has("discovered_resources") and Inventory:
		# Convert array back to dictionary format
		var discovered_array = data["discovered_resources"]
		Inventory.discovered_resources = {}
		for resource_id in discovered_array:
			Inventory.discovered_resources[resource_id] = true
	_apply_inventory(data.get(SaveSettings.SAVE_KEYS.inventory, {}))
	_apply_drones(int(data.get(SaveSettings.SAVE_KEYS.drones, 0)))

func _count_drones() -> int:
	"""Count drones using the group system instead of name checking"""
	return get_tree().get_nodes_in_group("drones").size()
	
func _apply_inventory(inv: Dictionary) -> void:
	"""Apply inventory data from save file"""
	var inv_node = Inventory
	if inv_node == null: return
	inv_node.stacks = inv.get(SaveSettings.SAVE_KEYS.stacks, {})
	var defaults = Balance.get_save_defaults()
	inv_node.used = int(inv.get(SaveSettings.SAVE_KEYS.used, defaults.inventory_used))
	inv_node.capacity = int(inv.get(SaveSettings.SAVE_KEYS.capacity, defaults.inventory_capacity))
	inv_node.credits = int(inv.get(SaveSettings.SAVE_KEYS.credits, defaults.inventory_credits))
	
	# Emit signals to update the UI
	inv_node.emit_signal("inventory_changed", "credits", inv_node.credits)
	for item_id in inv_node.stacks:
		inv_node.emit_signal("inventory_changed", item_id, inv_node.stacks[item_id])
	
func _apply_drones(n: int) -> void:
	"""Apply drone count from save file"""
	var mgr = get_tree().root.find_child("DroneManager", true, false)
	if mgr:
		for i in n:
			mgr.spawn_mining_drone()

func _apply_stamina(stamina_value: int) -> void:
	"""Apply stamina value from save file"""
	if Stamina:
		Stamina.set_stamina(stamina_value)
		print("Stamina loaded: ", stamina_value)

# Save Slot Management Functions
func set_current_slot(slot_number: int) -> void:
	"""Set the current save slot for auto-save"""
	if slot_number >= 1 and slot_number <= SaveSettings.MAX_SAVE_SLOTS:
		current_save_slot = slot_number
		print("Current save slot set to: ", slot_number)

func save_to_slot(slot_number: int) -> void:
	"""Save game to a specific slot"""
	print("Global: save_to_slot called with slot ", slot_number)
	if slot_number < 1 or slot_number > SaveSettings.MAX_SAVE_SLOTS:
		print("Invalid slot number: ", slot_number)
		return
	
	var slot_path = SaveSettings.get_slot_path(slot_number)
	var current_time = Time.get_unix_time_from_system()
	
	# Calculate cumulative playtime and get first play date
	var existing_playtime = 0
	var first_play_date = ""
	if FileAccess.file_exists(slot_path):
		# Load existing save to get current playtime and first play date
		var existing_file = FileAccess.open(slot_path, FileAccess.READ)
		var existing_txt = existing_file.get_as_text()
		existing_file.close()
		var existing_data = JSON.parse_string(existing_txt)
		if typeof(existing_data) == TYPE_DICTIONARY:
			var existing_metadata = existing_data.get(SaveSettings.SAVE_KEYS.metadata, {})
			existing_playtime = existing_metadata.get(SaveSettings.METADATA_KEYS.playtime, 0)
			first_play_date = existing_metadata.get(SaveSettings.METADATA_KEYS.first_play_date, "")
	
	# Add current session time to existing playtime
	var session_playtime = current_time - session_start_time
	var total_playtime = existing_playtime + int(session_playtime)
	
	# Create metadata with local time in readable format
	var local_time = Time.get_datetime_dict_from_system(false)  # false = local time, not UTC
	var month_names = ["", "January", "February", "March", "April", "May", "June",
					   "July", "August", "September", "October", "November", "December"]
	
	var month_name = month_names[local_time.month]
	var day = local_time.day
	
	# Format time with AM/PM
	var hour = local_time.hour
	var minute = local_time.minute
	var am_pm = "AM"
	if hour >= 12:
		am_pm = "PM"
	if hour > 12:
		hour -= 12
	elif hour == 0:
		hour = 12
	
	var time_str = "%d:%02d%s" % [hour, minute, am_pm]
	var timestamp_str = "%s %d, %s" % [month_name, day, time_str]
	
	# Set first play date if this is a new save
	if first_play_date == "":
		first_play_date = timestamp_str
	
	var metadata = {
		SaveSettings.METADATA_KEYS.timestamp: timestamp_str,
		SaveSettings.METADATA_KEYS.player_name: "Player",  # Could be customizable later
		SaveSettings.METADATA_KEYS.level: get_current_scene_name(),
		SaveSettings.METADATA_KEYS.playtime: total_playtime,
		SaveSettings.METADATA_KEYS.first_play_date: first_play_date
	}
	
	# Safely get inventory data with fallbacks
	var inventory_data := {}
	if Inventory:
		inventory_data = {
			SaveSettings.SAVE_KEYS.stacks: Inventory.stacks if Inventory.stacks else {},
			SaveSettings.SAVE_KEYS.used: Inventory.used if Inventory.used else 0,
			SaveSettings.SAVE_KEYS.capacity: Inventory.capacity if Inventory.capacity else 0,
			SaveSettings.SAVE_KEYS.credits: Inventory.credits if Inventory.credits else 0
		}
	
	# Safely get discovered resources
	var discovered_resources = []
	if Inventory and Inventory.has_method("get_discovered_resources"):
		discovered_resources = Inventory.get_discovered_resources()
	
	# Safely get stamina data
	var stamina_data = {}
	if Stamina:
		stamina_data = {
			SaveSettings.SAVE_KEYS.stamina: Stamina.get_current_stamina()
		}
	
	var data = {
		SaveSettings.SAVE_KEYS.metadata: metadata,
		SaveSettings.SAVE_KEYS.game_data: {
			SaveSettings.SAVE_KEYS.inventory: inventory_data,
			SaveSettings.SAVE_KEYS.drones: _count_drones(),
			SaveSettings.SAVE_KEYS.stamina: stamina_data.get(SaveSettings.SAVE_KEYS.stamina, Balance.get_max_stamina()),
			"discovered_resources": discovered_resources
		}
	}
	
	var file = FileAccess.open(slot_path, FileAccess.WRITE)
	if file == null:
		print("Global: ERROR - Failed to open file for writing: ", slot_path)
		return
	
	file.store_string(JSON.stringify(data))
	file.close()
	print("Global: Game saved to slot ", slot_number, " successfully")

func load_from_slot(slot_number: int) -> void:
	"""Load game from a specific slot"""
	if slot_number < 1 or slot_number > SaveSettings.MAX_SAVE_SLOTS:
		print("Invalid slot number: ", slot_number)
		return
	
	var slot_path = SaveSettings.get_slot_path(slot_number)
	if not FileAccess.file_exists(slot_path):
		print("No save file found in slot ", slot_number)
		return
	
	var file = FileAccess.open(slot_path, FileAccess.READ)
	var txt = file.get_as_text()
	file.close()
	var data = JSON.parse_string(txt)
	
	if typeof(data) != TYPE_DICTIONARY:
		print("Invalid save file format in slot ", slot_number)
		return
	
	# Set current slot and reset session timer
	current_save_slot = slot_number
	session_start_time = Time.get_unix_time_from_system()  # Reset session timer when loading
	
	# Load game data
	var game_data = data.get(SaveSettings.SAVE_KEYS.game_data, {})
	if game_data.has("discovered_resources") and Inventory:
		# Convert array back to dictionary format
		var discovered_array = game_data["discovered_resources"]
		Inventory.discovered_resources = {}
		for resource_id in discovered_array:
			Inventory.discovered_resources[resource_id] = true
	
	_apply_inventory(game_data.get(SaveSettings.SAVE_KEYS.inventory, {}))
	_apply_drones(int(game_data.get(SaveSettings.SAVE_KEYS.drones, 0)))
	_apply_stamina(int(game_data.get(SaveSettings.SAVE_KEYS.stamina, Balance.get_max_stamina())))
	
	print("Game loaded from slot ", slot_number)

func get_slot_info(slot_number: int) -> Dictionary:
	"""Get metadata for a specific save slot"""
	if slot_number < 1 or slot_number > SaveSettings.MAX_SAVE_SLOTS:
		return {}
	
	var slot_path = SaveSettings.get_slot_path(slot_number)
	if not FileAccess.file_exists(slot_path):
		return {"empty": true, "slot_number": slot_number}
	
	var file = FileAccess.open(slot_path, FileAccess.READ)
	var txt = file.get_as_text()
	file.close()
	var data = JSON.parse_string(txt)
	
	if typeof(data) != TYPE_DICTIONARY:
		return {"empty": true, "slot_number": slot_number}
	
	var metadata = data.get(SaveSettings.SAVE_KEYS.metadata, {})
	metadata["empty"] = false
	metadata["slot_number"] = slot_number
	return metadata

func get_all_slot_info() -> Array:
	"""Get metadata for all save slots"""
	var slots = []
	for i in range(1, SaveSettings.MAX_SAVE_SLOTS + 1):
		slots.append(get_slot_info(i))
	return slots

func delete_slot(slot_number: int) -> void:
	"""Delete a save slot"""
	if slot_number < 1 or slot_number > SaveSettings.MAX_SAVE_SLOTS:
		return
	
	var slot_path = SaveSettings.get_slot_path(slot_number)
	if FileAccess.file_exists(slot_path):
		DirAccess.remove_absolute(slot_path)
		print("Slot ", slot_number, " deleted")

func get_current_scene_name() -> String:
	"""Get the name of the current scene"""
	var current_scene = get_tree().current_scene
	if current_scene:
		return current_scene.scene_file_path.get_file().get_basename()
	return "Unknown"

func reset_game_data() -> void:
	"""Reset all game data for a new game"""
	# Reset game start time
	game_start_time = Time.get_unix_time_from_system()
	
	# Reset inventory if it exists
	if Inventory:
		var defaults = Balance.get_save_defaults()
		Inventory.stacks = {}
		Inventory.used = defaults.inventory_used
		Inventory.capacity = defaults.inventory_capacity
		Inventory.credits = defaults.inventory_credits
		Inventory.discovered_resources = {}
		
		# Emit signals to update UI
		Inventory.emit_signal("inventory_changed", "credits", Inventory.credits)
	
	# Clear all drones
	var drone_manager = get_tree().root.find_child("DroneManager", true, false)
	if drone_manager:
		# Remove all existing drones
		var drones = get_tree().get_nodes_in_group("drones")
		for drone in drones:
			drone.queue_free()
	
	# Reset stamina
	if Stamina:
		Stamina.reset_stamina()
	
	print("Game data reset for new game")

# Cave Level Management Functions
func get_cave_level() -> int:
	"""Get the current cave level"""
	return current_cave_level

func set_cave_level(level: int) -> void:
	"""Set the current cave level"""
	if level >= 1:
		current_cave_level = level
		print("Global: Cave level set to ", level)
	else:
		print("Global: Warning - Invalid cave level: ", level)

func advance_cave_level() -> void:
	"""Advance to the next cave level"""
	current_cave_level += 1
	print("Global: Advanced to cave level ", current_cave_level)
