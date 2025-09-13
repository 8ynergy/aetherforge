extends Node

signal purchase_succeeded(id: String)
signal purchase_failed(id: String, reason: String)

const OFFERS := {
	"miner_bot_mk1": {"cost": 50}
}

func _ready() -> void:
	purchase_succeeded.connect(_on_purchase)

func buy(id: String) -> void:
	var inv = get_tree().get_first_node_in_group("inventory")
	if inv == null or not OFFERS.has(id):
		emit_signal("purchase_failed", id, "locks or funds")
		return
	
	var error = inv.spend_credits(OFFERS[id].cost)
	if error != "":
		if error == "insufficient_funds_low":
			print("Insufficient funds.")
		emit_signal("purchase_failed", id, error)
		return
	
	emit_signal("purchase_succeeded", id)
	print("Purchase succeeded!")  # DEBUG: should appear in Output

func _on_purchase(id: String) -> void:
	if id == "miner_bot_mk1":
		var mgr = get_tree().root.find_child("DroneManager", true, false)
		if mgr:
			mgr.spawn_MiningDrone()
