extends Label
class_name DamageText

# Animation settings
@export var float_distance: float = 50.0
@export var animation_duration: float = 1.0
@export var fade_start_time: float = 0.5  # When to start fading out

var tween: Tween

func _ready() -> void:
	# Set up the label appearance
	add_theme_font_size_override("font_size", 12)
	add_theme_color_override("font_color", Color.WHITE)
	# Removed shadow settings for cleaner look
	
	# Start the floating animation
	start_animation()

func show_damage(damage: float, world_position: Vector2) -> void:
	"""Show damage text at the specified position with slight random variation"""
	text = str(int(damage))
	global_position = world_position
	
	# Add random variation to the position (±3 pixels)
	var random_offset_x = randf_range(-3.0, 3.0)
	var random_offset_y = randf_range(-3.0, 3.0)
	
	# Offset the text slightly above the click position with random variation
	global_position.x += random_offset_x
	global_position.y -= 20 + random_offset_y
	
	# Start the animation
	start_animation()

func start_animation() -> void:
	"""Start the floating and fade-out animation"""
	# Create tween for the animation
	tween = create_tween()
	tween.set_parallel(true)  # Allow multiple properties to animate simultaneously
	
	# Store initial position
	var start_pos = global_position
	var end_pos = start_pos + Vector2(0, -float_distance)
	
	# Animate upward movement
	tween.tween_property(self, "global_position", end_pos, animation_duration)
	
	# Animate fade out (start fading after fade_start_time)
	tween.tween_property(self, "modulate:a", 0.0, animation_duration - fade_start_time).set_delay(fade_start_time)
	
	# Clean up after animation completes
	tween.tween_callback(queue_free).set_delay(animation_duration)

func _on_animation_finished() -> void:
	"""Called when animation is complete"""
	queue_free()
