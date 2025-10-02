extends Node2D
class_name ResourceSpawner

# Configuration
@export var base_spawn_count: int = 20
@export var spawn_interval: float = 10.0
@export var grid_size: int = 64  # 32px tiles * 2 for spacing
@export var spawn_margin: int = 100  # Distance from screen edges

# Cave level system
var cave_level: int = 1
var resource_ratios: Dictionary = {
	1: {"stone": 5, "copper": 1}  # 5:1 ratio for level 1
}

# Scene references - will be set in _ready()
var mine_layer: Node2D
var camera: Camera2D
var collision_area: CollisionShape2D

# Resource scene paths
const RESOURCE_SCENES = {
	"stone": "res://scenes/world/Resources/NodeRock/NodeRock.tscn",
	"copper": "res://scenes/world/Resources/NodeCopper/NodeCopper.tscn"
}

# Grid tracking
var occupied_grid_positions: Dictionary = {}
var spawn_timer: Timer

func _ready() -> void:
	# Initialize scene references
	_initialize_scene_references()
	
	# Get cave level from Global singleton
	if Global.has_method("get_cave_level"):
		cave_level = Global.get_cave_level()
	
	# Get configuration from Balance singleton
	var spawn_settings = Balance.get_resource_spawn_settings()
	base_spawn_count = spawn_settings.get("base_spawn_count", base_spawn_count)
	spawn_interval = spawn_settings.get("spawn_interval", spawn_interval)
	grid_size = spawn_settings.get("grid_size", grid_size)
	spawn_margin = spawn_settings.get("spawn_margin", spawn_margin)
	
	# Get resource ratios for current cave level
	var cave_resources = Balance.get_cave_level_resources()
	if cave_resources.has(cave_level):
		resource_ratios[cave_level] = cave_resources[cave_level]
	
	# Wait one frame to ensure everything is ready, then spawn
	await get_tree().process_frame
	spawn_initial_resources()
	
	# Setup periodic spawning
	setup_spawn_timer()

func _initialize_scene_references() -> void:
	# Get scene references with proper error handling
	# ResourceSpawner is at SystemsRoot/ResourceSpawner, so we need to go up to SystemsRoot, then up to Main, then down to WorldRoot/MineLayer
	mine_layer = get_node("../../WorldRoot/MineLayer")
	if not mine_layer:
		print("ResourceSpawner: Warning - Could not find MineLayer node")
	
	# Try to find camera in the scene tree (it might be from a parent scene)
	camera = get_viewport().get_camera_2d()
	if not camera:
		print("ResourceSpawner: Warning - Could not find Camera2D in viewport")
	
	# CollisionShape2D is at Walls/StaticBody2D/CollisionShape2D from the main node
	collision_area = get_node("../../Walls/StaticBody2D/CollisionShape2D")
	if not collision_area:
		print("ResourceSpawner: Warning - Could not find CollisionShape2D node")

func spawn_initial_resources() -> void:
	print("ResourceSpawner: Spawning initial ", base_spawn_count, " resources for cave level ", cave_level)
	for i in range(base_spawn_count):
		spawn_single_resource()

func setup_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.autostart = true
	add_child(spawn_timer)
	print("ResourceSpawner: Setup spawn timer with interval ", spawn_interval, " seconds")

func _on_spawn_timer_timeout() -> void:
	spawn_single_resource()

func find_valid_spawn_position() -> Vector2:
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Get camera position with null check
	var camera_pos: Vector2
	if camera:
		camera_pos = camera.global_position
	else:
		# Try to get camera from viewport
		var viewport_camera = get_viewport().get_camera_2d()
		if viewport_camera:
			camera_pos = viewport_camera.global_position
		else:
			# Fallback to center of viewport if camera is not available
			camera_pos = Vector2(960, 540)  # Default center position
			print("ResourceSpawner: Warning - Camera not available, using fallback position")
	
	# Calculate spawnable area (camera view + margin)
	var min_x = camera_pos.x - viewport_size.x/2 - spawn_margin
	var max_x = camera_pos.x + viewport_size.x/2 + spawn_margin
	var min_y = camera_pos.y - viewport_size.y/2 - spawn_margin
	var max_y = camera_pos.y + viewport_size.y/2 + spawn_margin
	
	# Convert to grid coordinates
	var min_grid_x = int(min_x / grid_size)
	var max_grid_x = int(max_x / grid_size)
	var min_grid_y = int(min_y / grid_size)
	var max_grid_y = int(max_y / grid_size)
	
	# Try to find an empty grid position
	var attempts = 0
	var max_attempts = 100
	
	while attempts < max_attempts:
		var grid_x = randi_range(min_grid_x, max_grid_x)
		var grid_y = randi_range(min_grid_y, max_grid_y)
		var grid_key = Vector2i(grid_x, grid_y)
		
		# Check if position is occupied
		if not occupied_grid_positions.has(grid_key):
			# Check collision with existing CollisionShape2D
			var world_pos = Vector2(grid_x * grid_size, grid_y * grid_size)
			if not is_position_blocked(world_pos):
				occupied_grid_positions[grid_key] = true
				return world_pos
		
		attempts += 1
	
	# Fallback: return a random position if no valid grid position found
	print("ResourceSpawner: Warning - Could not find valid grid position, using fallback")
	return Vector2(
		randf_range(min_x, max_x),
		randf_range(min_y, max_y)
	)

func is_position_blocked(pos: Vector2) -> bool:
	if not collision_area:
		return false
	
	# Get the collision shape bounds
	var shape = collision_area.shape as RectangleShape2D
	if not shape:
		return false
	
	var collision_pos = collision_area.global_position
	var collision_size = shape.size
	
	# Check if position is within collision area
	var rect = Rect2(
		collision_pos.x - collision_size.x/2,
		collision_pos.y - collision_size.y/2,
		collision_size.x,
		collision_size.y
	)
	
	return rect.has_point(pos)

func select_resource_type() -> String:
	var ratios = resource_ratios.get(cave_level, {"stone": 1})
	var total_weight = 0
	
	# Calculate total weight
	for resource in ratios:
		total_weight += ratios[resource]
	
	if total_weight == 0:
		return "stone"  # Fallback
	
	# Random selection based on weights
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for resource in ratios:
		current_weight += ratios[resource]
		if random_value < current_weight:
			return resource
	
	return "stone"  # Fallback

func spawn_single_resource() -> void:
	# Check if mine_layer is available
	if not mine_layer:
		print("ResourceSpawner: Warning - MineLayer not available, cannot spawn resource")
		return
	
	var resource_type = select_resource_type()
	var scene_path = RESOURCE_SCENES.get(resource_type)
	
	if not scene_path:
		print("ResourceSpawner: Warning - No scene path found for resource type: ", resource_type)
		return
	
	# Load and instantiate resource
	var resource_scene = load(scene_path)
	if not resource_scene:
		print("ResourceSpawner: Warning - Could not load scene: ", scene_path)
		return
	
	var resource_instance = resource_scene.instantiate()
	
	# Set position
	var spawn_pos = find_valid_spawn_position()
	resource_instance.global_position = spawn_pos
	
	# Add to mine layer
	mine_layer.add_child(resource_instance)
	
	# Connect to depletion signal to free up grid position
	resource_instance.resource_depleted.connect(_on_resource_depleted)
	
	print("ResourceSpawner: Spawned ", resource_type, " at position ", spawn_pos)

func _on_resource_depleted(node: ResourceNode, resource_type: String, _amount: int) -> void:
	# Convert world position back to grid coordinates
	var grid_x = int(node.global_position.x / grid_size)
	var grid_y = int(node.global_position.y / grid_size)
	var grid_key = Vector2i(grid_x, grid_y)
	
	# Free up the grid position
	occupied_grid_positions.erase(grid_key)
	print("ResourceSpawner: Freed grid position for ", resource_type, " at ", grid_key)

# Public methods for external control
func set_cave_level(level: int) -> void:
	cave_level = level
	var cave_resources = Balance.get_cave_level_resources()
	if cave_resources.has(cave_level):
		resource_ratios[cave_level] = cave_resources[cave_level]
	print("ResourceSpawner: Set cave level to ", cave_level)

func get_cave_level() -> int:
	return cave_level

func clear_all_resources() -> void:
	# Check if mine_layer is available
	if not mine_layer:
		print("ResourceSpawner: Warning - MineLayer not available, cannot clear resources")
		return
	
	# Clear all spawned resources
	for child in mine_layer.get_children():
		if child is ResourceNode:
			child.queue_free()
	
	# Clear grid tracking
	occupied_grid_positions.clear()
	print("ResourceSpawner: Cleared all resources and grid positions")
