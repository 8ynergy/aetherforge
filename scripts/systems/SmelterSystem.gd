extends Node

signal smelt_complete(item: String, qty: int)

var queue: Array = [] # Array[Dictionary] e.g. [{id:"stone", in:10, out:"stone_bar", out_qty:1, time:2.0, t:0}]
const RECIPE := GameBalance.SMELT_RECIPES

func _ready() -> void:
	set_process(true)

func enqueue(item: String, qty_in: int) -> bool:
	if not RECIPE.has(item):
		return false
	var inv = get_tree().get_first_node_in_group("inventory")
	if inv == null: 
		return false
	if inv.get_qty(item) < qty_in: 
		return false
	
	# remove inputs	
	inv.add(item, -qty_in)
	
	var r: Dictionary = RECIPE[item]
	queue.append({
		"id": item, 
		"in": qty_in, 
		"out": r.out, 
		"out_qty": r.out_qty, 
		"time": r.time, 
		"t": 0.0
	})
	return true

func _process(delta: float) -> void:
	if queue.is_empty(): 
		return
	queue[0].t += delta
	if queue[0]["t"] >= float(queue[0]["time"]):
		var job = queue.pop_front()
		var inv = get_tree().get_first_node_in_group("inventory")
		if inv:
			inv.add(String(job["out"]), int(job["out_qty"]))
			emit_signal("smelt_complete", String(job["out"]), int(job["out_qty"]))
			print("Smelter complete ->", job["out"], job["out_qty"])  # DEBUG
