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

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		pass

func _on_mouse_entered() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", true)

func _on_mouse_exited() -> void:
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)
