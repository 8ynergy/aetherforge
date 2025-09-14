extends Node

const SAVE_PATH := SaveSettings.SAVE_PATH

func save_game() -> void:
	var inv = get_tree().get_first_node_in_group("inventory")
	var data := {
		SaveSettings.SAVE_KEYS.inventory: {
			SaveSettings.SAVE_KEYS.stacks: inv.stacks,
			SaveSettings.SAVE_KEYS.used: inv.used,
			SaveSettings.SAVE_KEYS.capacity: inv.capacity,
			SaveSettings.SAVE_KEYS.credits: inv.credits
		},
		SaveSettings.SAVE_KEYS.drones: _count_drones()
	}
	var file = FileAccess.open(SaveSettings.SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SaveSettings.SAVE_PATH):
		return
	var file = FileAccess.open(SaveSettings.SAVE_PATH, FileAccess.READ)
	var txt = file.get_as_text()
	file.close()
	var data = JSON.parse_string(txt)
	if typeof(data) != TYPE_DICTIONARY:
		return
	_apply_inventory(data.get(SaveSettings.SAVE_KEYS.inventory, {}))
	_apply_drones(int(data.get(SaveSettings.SAVE_KEYS.drones, 0)))

func _count_drones() -> int:
	var world = get_tree().get_current_scene().get_node("WorldRoot")
	return world.get_children().filter(func(c): return c is Node2D and c.name.begins_with(SaveSettings.DRONE_NAME_PREFIX)).size()
	
func _apply_inventory(inv: Dictionary) -> void:
	var inv_node = get_tree().get_first_node_in_group("inventory")
	if inv_node == null: return
	inv_node.stacks = inv.get(SaveSettings.SAVE_KEYS.stacks, {})
	inv_node.used = int(inv.get(SaveSettings.SAVE_KEYS.used, GameBalance.SAVE_DEFAULTS.inventory_used))
	inv_node.capacity = int(inv.get(SaveSettings.SAVE_KEYS.capacity, GameBalance.SAVE_DEFAULTS.inventory_capacity))
	inv_node.credits = int(inv.get(SaveSettings.SAVE_KEYS.credits, GameBalance.SAVE_DEFAULTS.inventory_credits))
	
	# Emit signals to update the UI
	inv_node.emit_signal("inventory_changed", "credits", inv_node.credits)
	for item_id in inv_node.stacks:
		inv_node.emit_signal("inventory_changed", item_id, inv_node.stacks[item_id])
	
func _apply_drones(n: int) -> void:
	var mgr = get_tree().root.find_child("DroneManager", true, false)
	if mgr:
		for i in n:
			mgr.spawn_mining_drone()
