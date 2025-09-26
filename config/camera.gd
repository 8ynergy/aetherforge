extends Camera2D

@export_range(0.0, 1.0, 0.01) var max_offset_pct_x: float = 0.25
@export_range(0.0, 1.0, 0.01) var max_offset_pct_y: float = 0.25
@export var responsiveness: float = 8.0
@export_range(0.0, 0.5, 0.01) var dead_zone: float = 0.05
@export var curve_edges: bool = true

func _ready() -> void:
	make_current()		# Activate this camera in Godot 4.x
						# Alternatively: enabled = true
	position = Vector2(1920, 1080) * 0.5

func _process(delta: float) -> void:
	var vp: Viewport = get_viewport()
	if vp == null:
		return

	# Use visible rect so Expand/Integer scaling letterbox is handled correctly
	var vis: Rect2i = vp.get_visible_rect()
	var size_px: Vector2 = Vector2(vis.size)   # cast Vector2i -> Vector2
	if size_px.x <= 0.0 or size_px.y <= 0.0:
		return

	var mouse_px: Vector2 = vp.get_mouse_position()
	var half: Vector2 = size_px * 0.5
	var from_center: Vector2 = mouse_px - half

	# Normalize to [-1, 1] each axis
	var norm: Vector2 = Vector2(
		clamp(from_center.x / half.x, -1.0, 1.0),
		clamp(from_center.y / half.y, -1.0, 1.0)
	)

	if dead_zone > 0.0:
		norm = _apply_dead_zone(norm, dead_zone)

	if curve_edges:
		norm = Vector2(_signed_square(norm.x), _signed_square(norm.y))

	# Max offset in pixels, derived from percent of half-screen
	var max_offset_px: Vector2 = Vector2(half.x * max_offset_pct_x, half.y * max_offset_pct_y)

	var target: Vector2 = norm * max_offset_px

	# Framerate-independent smoothing
	var alpha: float = 1.0 - exp(-responsiveness * delta)
	offset = offset.lerp(target, alpha)

func _signed_square(v: float) -> float:
	return v * abs(v)

func _apply_dead_zone(v: Vector2, dz: float) -> Vector2:
	return Vector2(
		shrink_axis(v.x, dz),
		shrink_axis(v.y, dz)
	)

func shrink_axis(a: float, dz: float) -> float:
	var s: float = sign(a)
	var abs_a: float = abs(a)
	if abs_a <= dz:
		return 0.0
	# remap [dz..1] → [0..1]
	var t: float = (abs_a - dz) / (1.0 - dz)
	return s * t
