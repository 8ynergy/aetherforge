extends Node

signal purchase_succeeded(id: String)
signal purchase_failed(id: String, reason: String)

const OFFERS := ItemDatabase.SHOP_OFFERS

func _ready() -> void:
	purchase_succeeded.connect(_on_purchase)

func buy(id: String) -> void:
	if not OFFERS.has(id):
		emit_signal("purchase_failed", id, "item_not_available")
		return
	
	var error = Inventory.spend_credits(OFFERS[id].cost)
	if error != "":
		if error == "insufficient_funds_low":
			print("Insufficient funds.")
		emit_signal("purchase_failed", id, error)
		return
	
	emit_signal("purchase_succeeded", id)
	print("Purchase succeeded!")  # DEBUG: should appear in Output

func _on_purchase(id: String) -> void:
	if id == "mining_drone_mk1":
		var mgr = get_tree().root.find_child("DroneManager", true, false)
		if mgr:
			mgr.spawn_mining_drone()
