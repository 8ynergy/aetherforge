extends Area2D
class_name ResourceNode


@export var max_hp: int = 2
@export var resource_type: String
@export var resource_amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var hp: int
var active_particle_effects: Array[GPUParticles2D] = []

signal resource_depleted(node: ResourceNode, resource_type: String, amount: int)

func _ready() -> void:
	hp = max_hp
	input_pickable = true

func _input_event(_viewport, event, _shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Store the click position for particle effect
		var click_position = get_global_mouse_position()
		
		# Only consume stamina in Mine scene
		var current_scene = get_tree().current_scene
		if current_scene and current_scene.name == "Main":
			# Check if player has enough stamina to mine
			var stamina_cost = Balance.get_mining_stamina_cost()
			print("ResourceNode: Clicked in Mine scene, stamina cost: ", stamina_cost)
			if Stamina and Stamina.can_consume_stamina(stamina_cost):
				print("ResourceNode: Consuming stamina...")
				# Consume stamina first
				var success = Stamina.consume_stamina(stamina_cost)
				print("ResourceNode: Stamina consumption result: ", success)
				# Then mine the resource
				var dmg := Balance.click_damage()
				_hit(dmg, click_position)
			else:
				print("Not enough stamina to mine! Need: ", stamina_cost, " stamina")
				# Could add visual feedback here for insufficient stamina
		else:
			# In other scenes, mine without stamina cost
			print("Resource node clicked!")  # DEBUG
			var dmg := Balance.click_damage()
			_hit(dmg, click_position)

func _hit(dmg: float, click_position: Vector2 = Vector2.ZERO) -> void:
	hp -= int(dmg)
	_show_hit_effect()
	_show_damage_text(dmg)
	_show_click_particles(click_position)
	
	if hp <= 0:
		# Don't immediately deplete - let particles finish first
		await get_tree().create_timer(0.1).timeout
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
	
	# Get configurable hit effect settings
	var settings = Balance.get_hit_effect_settings()
	var duration = Balance.get_hit_effect_duration()  # Can be modified by speed multiplier later
	
	# Flash white on hit: brighten sprite to max brightness, then fade to normal over configurable duration
	tween.tween_property(sprite, "modulate:v", settings.brightness_end, duration).from(settings.brightness_start)

func _show_damage_text(damage: float) -> void:
	"""Show floating damage text above the resource node"""
	# Load the damage text scene
	var damage_text_scene = preload("res://scenes/ui/DamageText.tscn")
	if not damage_text_scene:
		print("ResourceNode: Could not load DamageText scene")
		return
	
	# Create the damage text instance
	var damage_text = damage_text_scene.instantiate()
	if not damage_text:
		print("ResourceNode: Could not instantiate DamageText")
		return
	
	# Find the appropriate parent node to add the damage text to
	# We want to add it to a UI layer that's above the world
	var ui_root = get_tree().current_scene.get_node("UIRoot")
	if not ui_root:
		print("ResourceNode: Could not find UIRoot for damage text")
		damage_text.queue_free()
		return
	
	# Add the damage text to the UI root
	ui_root.add_child(damage_text)
	
	# Show the damage at the resource node's position
	damage_text.show_damage(damage, global_position)

func _show_click_particles(click_position: Vector2 = Vector2.ZERO) -> void:
	"""Show particle burst effect on resource node click"""
	# Load the particle effect scene
	var particle_scene = preload("res://scenes/effects/ClickParticleEffect.tscn")
	if not particle_scene:
		print("ResourceNode: Could not load ClickParticleEffect scene")
		return
	
	# Create the particle effect instance
	var particle_effect = particle_scene.instantiate()
	if not particle_effect:
		print("ResourceNode: Could not instantiate ClickParticleEffect")
		return
	
	# Position the effect at the click position (or node position if no click position provided)
	var effect_position = click_position if click_position != Vector2.ZERO else global_position
	particle_effect.global_position = effect_position
	
	# Add to the scene (add to the same parent as the resource node)
	get_parent().add_child(particle_effect)
	
	# Start the particle emission
	particle_effect.emitting = true
	
	# Track this particle effect
	active_particle_effects.append(particle_effect)
	
	# Auto-cleanup after the effect finishes
	await get_tree().create_timer(0.4).timeout
	if is_instance_valid(particle_effect):
		particle_effect.queue_free()
		active_particle_effects.erase(particle_effect)

func _deplete() -> void:
	emit_signal("resource_depleted", self, resource_type, resource_amount)
	
	# Stop all active particle effects
	for particle_effect in active_particle_effects:
		if is_instance_valid(particle_effect):
			particle_effect.emitting = false
			particle_effect.queue_free()
	active_particle_effects.clear()
	
	# Add resources to inventory before destroying
	Inventory.add_to_inventory(resource_type, resource_amount)
	
	# Destroy the node instead of respawning
	queue_free()

func _process(_d):
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.show_debug("Resource HP: %d/%d" % [hp, max_hp])
