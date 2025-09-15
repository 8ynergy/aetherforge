extends Control

# UI references
@onready var credits_label: Label = $CreditsLabel
@onready var stone_label: Label = $StoneLabel
@onready var bar_label: Label = $BarLabel
@onready var smelt_btn: Button = $SmeltButton
@onready var buy_drone_btn: Button = $BuyDroneButton
@onready var pause_btn: Button = $PauseButton

var _inv: Node = null

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE  # Allow clicks to pass through to world objects
	
	# Connect button signals
	if smelt_btn:
		smelt_btn.pressed.connect(_on_smelt_pressed)
	if buy_drone_btn:
		buy_drone_btn.pressed.connect(_on_buy_drone_pressed)
	if pause_btn:
		pause_btn.pressed.connect(_on_pause_pressed)
	
	_bind_inventory()
	_refresh_all()

func _on_pause_pressed():
	# Find the pause menu in the scene tree
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu:
		pause_menu.toggle_pause_menu()

func _on_smelt_pressed():
	var smelter = get_tree().root.find_child("Smelter", true, false)
	if smelter and smelter.enqueue("stone", 10):
		print("Enqueued 10 stone")
	else:
		print("Failed to enqueue")

func _on_buy_drone_pressed():
	var shop = get_tree().root.find_child("ShopSystem", true, false)
	if shop:
		shop.buy("mining_drone_mk1")
	
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
	if _inv and _inv.has_method("get_credits") and credits_label:
		credits_label.text = "Credits: %d" % int(_inv.call("get_credits"))
	if _inv and _inv.has_method("get_qty") and stone_label:
		stone_label.text = "Stone: %d" % int(_inv.call("get_qty", "stone"))
	if _inv and _inv.has_method("get_qty") and bar_label:
		bar_label.text = "Stone Bars: %d" % int(_inv.call("get_qty", "stone_bar"))
