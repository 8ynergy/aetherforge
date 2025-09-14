extends ResourceNode

func _ready() -> void:
	super._ready()
	resource_type = "gold"
	resource_amount = 1
	var settings = Balance.get_resource_node_settings("gold")
	max_hp = settings.max_hp
	hp = max_hp
