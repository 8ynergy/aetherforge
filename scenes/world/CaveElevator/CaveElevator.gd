extends Area2D

@onready var mat := $Sprite2D.material as ShaderMaterial

func _ready() -> void:
	# Check if Material shader is empty
	if mat == null:
		push_warning("No ShaderMaterial assigned; hover outline won't appear.")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Get the current scene's filename
		var current_scene = get_tree().current_scene.scene_file_path.get_file()
		
		if current_scene == "Main.tscn":
			var target_scene_path = "res://scenes/main/Camp.tscn"
			get_tree().change_scene_to_file(target_scene_path)
			if mat:
				mat.set_shader_parameter("OnHoverShader", false)
		if current_scene == "Camp.tscn":
			var target_scene_path = "res://scenes/main/Main.tscn"
			get_tree().change_scene_to_file(target_scene_path)
			if mat:
				mat.set_shader_parameter("OnHoverShader", false)

func _on_mouse_entered() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", true)

func _on_mouse_exited() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)
