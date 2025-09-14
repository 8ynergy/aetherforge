extends Area2D

@export var max_hp: int = GameBalance.ROCK_MAX_HP
var hp: int = GameBalance.ROCK_MAX_HP

signal rock_broken(table_id: String)

func _ready() -> void:
	input_pickable = true  # ensure the Area2D can receive mouse input

func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Rock clicked!")  # DEBUG: should appear in Output
		var dmg := Balance.click_damage()
		_hit(dmg)

func _hit(dmg: float) -> void:
	hp -= int(dmg)
	if hp <= 0:
		emit_signal("rock_broken", "stone_basic")
		_respawn()

func _respawn() -> void:
	var inv := get_tree().get_first_node_in_group("inventory")
	if inv == null:
		# mark Inventory node to group "inventory" in Main.tscn (Node → Groups)
		inv = get_tree().root.find_child("Inventory", true, false)
	if inv:
		inv.add("stone", 1)
	hp = max_hp

func _process(_d):
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_debug("Rock HP: %d/%d" % [hp, max_hp])
