class_name ResourceNode
extends Area2D

@export var max_hp: int = 2
@export var resource_type: String = "stone"
@export var resource_amount: int = 1

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
    if hp <= 0:
        _deplete()

func _deplete() -> void:
    emit_signal("resource_depleted", self, resource_type, resource_amount)
    _respawn()

func _respawn() -> void:
    var inv := get_tree().get_first_node_in_group("inventory")
    if inv == null:
        inv = get_tree().root.find_child("Inventory", true, false)
    if inv:
        inv.add(resource_type, resource_amount)
    hp = max_hp

func _process(_d):
    var hud := get_tree().get_first_node_in_group("hud")
    if hud:
        hud.show_debug("Resource HP: %d/%d" % [hp, max_hp])
