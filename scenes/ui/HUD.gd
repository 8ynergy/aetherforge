extends Control

# RESOURCE LABELS
@onready var credits_label: Label = Label.new()
@onready var stone_label: Label = Label.new()
@onready var bar_label := Label.new()

# BUTTONS
@onready var smelt_btn := Button.new()
@onready var buy_drone_btn := Button.new()
@onready var save_btn := Button.new()
@onready var load_btn := Button.new()

var _inv: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# RESOURCE LABELS
	credits_label.position = Vector2(8, 8)
	stone_label.position = Vector2(8, 24)
	bar_label.position = Vector2(8, 40)
	
	add_child(credits_label)
	add_child(stone_label)
	add_child(bar_label)
	
	# BUTTONS
	smelt_btn.text = "Smelt 10 Stone (10)"
	smelt_btn.position = Vector2(8, 64)
	buy_drone_btn.text = "Buy Mining Drone ($50)"
	buy_drone_btn.position = Vector2(8, 96)
	save_btn.text = "Save"
	save_btn.position = Vector2(8, 128)
	load_btn.text = "Load"
	load_btn.position = Vector2(70, 128)
	
	add_child(smelt_btn)
	add_child(buy_drone_btn)
	add_child(save_btn)
	add_child(load_btn)
	
	_bind_inventory()
	_refresh_all()
	
	smelt_btn.pressed.connect(func():
		var smelter = get_tree().root.find_child("Smelter", true, false)
		if smelter and smelter.enqueue("stone", 10):
			print("Enqueued 10 stone")
		else:
			print("Failed to enqueue (not enough stone or Smelter not found)")
	)
	
	buy_drone_btn.pressed.connect(func():
		var shop = get_tree().root.find_child("ShopSystem", true, false)
		if shop:
			shop.buy("mining_drone_mk1")
	)
	
	save_btn.pressed.connect(func():
		var saver = get_tree().root.find_child("SaveSys", true, false)
		if saver: saver.save_game()
	)
	
	load_btn.pressed.connect(func():
		var saver = get_tree().root.find_child("SaveSys", true, false)
		if saver: saver.load_game()
	)
	
func _bind_inventory() -> void:
	var main := get_tree().get_current_scene()
	if main and main.has_node("SystemsRoot/Inventory"):
		_inv = main.get_node("SystemsRoot/Inventory")
	else:
		_inv = get_tree().get_first_node_in_group("inventory")
	if _inv and not _inv.is_connected("inventory_changed", Callable(self, "_on_inventory_changed")):
		_inv.connect("inventory_changed", Callable(self, "_on_inventory_changed"))

func _on_inventory_changed(_id: String, _qty: int) -> void:
	_refresh_all()

func _refresh_all() -> void:
	# _inv connects to Inventory.gd
	if _inv and _inv.has_method("get_credits"):
		credits_label.text = "Credits: %d" % int(_inv.call("get_credits"))
	if _inv and _inv.has_method("get_qty"):
		stone_label.text = "Stone: %d" % int(_inv.call("get_qty", "stone"))
		bar_label.text   = "Stone Bars: %d" % int(_inv.call("get_qty", "stone_bar"))
