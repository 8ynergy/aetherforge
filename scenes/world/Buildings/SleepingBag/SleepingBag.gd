extends Area2D

@onready var mat := $Sprite2D.material as ShaderMaterial

func _ready() -> void:
	# Create a unique material instance
	var original_mat = $Sprite2D.material as ShaderMaterial
	if original_mat:
		mat = original_mat.duplicate()
		$Sprite2D.material = mat
	else:
		push_warning("No ShaderMaterial assigned; hover outline won't appear.")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("SleepingBag: Clicked!")
		# Only allow stamina restoration in Camp scene
		var current_scene = get_tree().current_scene
		print("SleepingBag: Current scene name: ", current_scene.name if current_scene else "null")
		if current_scene and current_scene.name == "Camp":
			print("SleepingBag: In Camp scene, checking Stamina singleton...")
			# Start stamina restoration when sleeping bag is clicked
			if Stamina:
				print("SleepingBag: Stamina singleton found, current restoring state: ", Stamina.is_restoring)
				if Stamina.is_restoring:
					# Stop restoration if already restoring
					Stamina.stop_restoration()
					print("SleepingBag: Stopped stamina restoration")
				else:
					# Start restoration if not already restoring
					Stamina.start_restoration()
					print("SleepingBag: Started stamina restoration")
			else:
				print("SleepingBag: Stamina singleton not found!")
		else:
			print("SleepingBag: Stamina restoration only available in Camp scene")

func _on_mouse_entered() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", true)

func _on_mouse_exited() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)
