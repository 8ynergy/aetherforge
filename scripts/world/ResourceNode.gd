class_name ResourceNode
extends Area2D

@export var max_hp: int = 2
@export var resource_type: String = "stone"
@export var resource_amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var hp: int

signal resource_depleted(node: ResourceNode, resource_type: String, amount: int)

func _ready() -> void:
	hp = max_hp
	input_pickable = true

func _input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Resource node clicked!")  # DEBUG
		var dmg := Balance.click_damage()
		_hit(dmg)

func _hit(dmg: float) -> void:
	hp -= int(dmg)
	_show_hit_effect()
	
	if hp <= 0:
		_deplete()

func _show_hit_effect() -> void:
	var tween: Tween = create_tween()
	
	if sprite == null:
		print("Sprite is null!")  # Debug
		return
	
	# Create a tween for the white blink effect
	if tween == null:
		print("Tween is null. Failed to create tween!")
		return
	
	tween.tween_property(sprite, "modulate:v", 1, 0.25).from(15)

func _deplete() -> void:
	emit_signal("resource_depleted", self, resource_type, resource_amount)
	
	# Add resources to inventory before destroying
	var inv := get_tree().get_first_node_in_group("inventory")
	if inv == null:
		inv = get_tree().root.find_child("Inventory", true, false)
	if inv:
		inv.add(resource_type, resource_amount)
	
	# Destroy the node instead of respawning
	queue_free()

func _process(_d):
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_debug("Resource HP: %d/%d" % [hp, max_hp])
