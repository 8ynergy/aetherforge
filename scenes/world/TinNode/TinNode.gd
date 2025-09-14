extends ResourceNode

func _ready() -> void:
	super._ready()
	resource_type = "tin"
	resource_amount = 1
	var settings = Balance.get_resource_node_settings("tin")
	max_hp = settings.max_hp
	hp = max_hp
