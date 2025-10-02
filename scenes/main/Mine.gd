extends Node2D

@onready var resource_spawner: Node2D = $SystemsRoot/ResourceSpawner

func _ready() -> void:
	# Initialize the mine scene
	print("Mine scene loaded - Resource spawner initialized")

# Test functions for debugging
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				# Test: Spawn a single resource
				if resource_spawner:
					resource_spawner.spawn_single_resource()
			KEY_2:
				# Test: Clear all resources
				if resource_spawner:
					resource_spawner.clear_all_resources()
			KEY_3:
				# Test: Change cave level
				if resource_spawner:
					var current_level = resource_spawner.get_cave_level()
					var new_level = (current_level % 3) + 1
					resource_spawner.set_cave_level(new_level)
					print("Changed cave level to: ", new_level)
