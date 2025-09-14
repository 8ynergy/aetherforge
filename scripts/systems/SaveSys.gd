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
	# Count drones using the group system instead of name checking
	return get_tree().get_nodes_in_group("drones").size()
	
func _apply_inventory(inv: Dictionary) -> void:
	var inv_node = get_tree().get_first_node_in_group("inventory")
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
	var mgr = get_tree().root.find_child("DroneManager", true, false)
	if mgr:
		for i in n:
			mgr.spawn_mining_drone()
