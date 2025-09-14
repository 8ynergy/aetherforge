extends ResourceNode

func _ready() -> void:
	super._ready()
	resource_type = "silver"
	resource_amount = 1
	var settings = Balance.get_resource_node_settings("silver")
	max_hp = settings.max_hp
	hp = max_hp
