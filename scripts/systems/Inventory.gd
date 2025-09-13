extends Node

signal inventory_changed(id: String, qty: int)

var capacity := 200
var used := 0
var stacks := {} # {id: qty}
var credits := 100 # starting credits

func add(id: String, qty: int) -> int:
	var space: int = max(capacity - used, 0)
	var to_add: int = min(qty, space)
	stacks[id] = int(stacks.get(id, 0)) + to_add
	used += to_add
	if to_add > 0:
		emit_signal("inventory_changed", id, stacks[id])
	return qty - to_add

func get_qty(id: String) -> int:
	return int(stacks.get(id, 0))

func get_credits() -> int:
	return credits

func spend_credits(amount: int) -> String: # Returns error message, empty string if success
	if credits < amount:
		return "insufficient_funds_low" # Always print the message for any insufficient funds

	credits -= amount
	emit_signal("inventory_changed", "credits", credits)
	return "" # Success
