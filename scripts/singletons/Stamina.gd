extends Node

# Stamina system singleton
# Manages player stamina, restoration, and consumption

signal stamina_changed(current_stamina: int, max_stamina: int)
signal stamina_depleted()
signal stamina_restored()
signal restoration_started()
signal restoration_stopped()

# Current stamina state
var current_stamina: int = 1000
var max_stamina: int = 1000
var is_restoring: bool = false

# Restoration settings
var restoration_rate: float = 10.0  # stamina per second
var restoration_timer: float = 0.0
var restoration_interval: float = 0.1  # Update every 0.1 seconds

# Scene tracking for manual check
var last_scene_name: String = ""

func _ready() -> void:
	# Initialize stamina from Balance singleton
	_initialize_stamina()
	
	# Try to connect to scene change signals to stop restoration when leaving Camp
	# Use a safer approach that works across Godot versions
	if get_tree().has_signal("scene_changed"):
		get_tree().scene_changed.connect(_on_scene_changed)
		print("Stamina: Connected to scene_changed signal")
	else:
		print("Stamina: scene_changed signal not available, using manual check")
	
	print("Stamina singleton initialized")

func _process(delta: float) -> void:
	# Manual scene check as fallback if signal connection failed
	_check_scene_change()
	
	if is_restoring:
		_handle_stamina_restoration(delta)

func _initialize_stamina() -> void:
	"""Initialize stamina values from Balance singleton"""
	max_stamina = Balance.get_max_stamina()
	current_stamina = max_stamina
	restoration_rate = Balance.get_stamina_restore_rate()
	print("Stamina initialized: ", current_stamina, "/", max_stamina)

func consume_stamina(amount: int) -> bool:
	"""Consume stamina and return true if successful"""
	if current_stamina >= amount:
		current_stamina -= amount
		current_stamina = max(0, current_stamina)
		print("Stamina: Emitting stamina_changed signal with values: ", current_stamina, "/", max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)
		
		if current_stamina <= 0:
			stamina_depleted.emit()
		
		print("Stamina consumed: ", amount, " (", current_stamina, "/", max_stamina, ")")
		return true
	else:
		print("Not enough stamina! Need: ", amount, ", Have: ", current_stamina)
		return false

func can_consume_stamina(amount: int) -> bool:
	"""Check if player has enough stamina"""
	return current_stamina >= amount

func start_restoration() -> void:
	"""Start stamina restoration (when in sleeping bag)"""
	print("Stamina: start_restoration() called, current state: ", is_restoring)
	if not is_restoring:
		is_restoring = true
		restoration_timer = 0.0
		restoration_started.emit()
		print("Stamina: Restoration started - is_restoring set to: ", is_restoring)
	else:
		print("Stamina: Already restoring, ignoring start request")

func stop_restoration() -> void:
	"""Stop stamina restoration"""
	if is_restoring:
		is_restoring = false
		restoration_stopped.emit()
		print("Stamina restoration stopped")

func _handle_stamina_restoration(delta: float) -> void:
	"""Handle stamina restoration over time"""
	if current_stamina >= max_stamina:
		print("Stamina: Already at max, stopping restoration")
		stop_restoration()
		return

	restoration_timer += delta

	# Restore stamina at the configured rate
	if restoration_timer >= restoration_interval:
		var restore_amount = restoration_rate * restoration_interval
		var old_stamina = current_stamina
		current_stamina += int(restore_amount)
		current_stamina = min(current_stamina, max_stamina)
		
		print("Stamina: Restoring ", int(restore_amount), " stamina (", old_stamina, " -> ", current_stamina, ")")

		stamina_changed.emit(current_stamina, max_stamina)

		if current_stamina >= max_stamina:
			stamina_restored.emit()
			stop_restoration()

		restoration_timer = 0.0

func get_stamina_percentage() -> float:
	"""Get current stamina as a percentage (0.0 to 1.0)"""
	return float(current_stamina) / float(max_stamina)

func is_stamina_depleted() -> bool:
	"""Check if stamina is completely depleted"""
	return current_stamina <= 0

func get_current_stamina() -> int:
	"""Get current stamina value"""
	return current_stamina

func get_max_stamina() -> int:
	"""Get maximum stamina value"""
	return max_stamina

func set_stamina(value: int) -> void:
	"""Set stamina to a specific value (for save/load)"""
	current_stamina = clamp(value, 0, max_stamina)
	stamina_changed.emit(current_stamina, max_stamina)
	print("Stamina set to: ", current_stamina, "/", max_stamina)

func reset_stamina() -> void:
	"""Reset stamina to maximum (for new game)"""
	current_stamina = max_stamina
	is_restoring = false
	stamina_changed.emit(current_stamina, max_stamina)
	print("Stamina reset to maximum: ", current_stamina)

func _check_scene_change() -> void:
	"""Manual scene change detection as fallback"""
	var current_scene = get_tree().current_scene
	var current_scene_name = current_scene.name if current_scene else ""
	
	if current_scene_name != last_scene_name:
		last_scene_name = current_scene_name
		_on_scene_changed()

func _on_scene_changed() -> void:
	"""Handle scene changes - stop restoration if leaving Camp"""
	var current_scene = get_tree().current_scene
	if current_scene:
		print("Stamina: Scene changed to: ", current_scene.name)
		if current_scene.name != "Camp" and is_restoring:
			print("Stamina: Left Camp scene, stopping restoration")
			stop_restoration()
	else:
		print("Stamina: Scene changed to null")
