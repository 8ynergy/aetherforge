extends Area2D

@onready var static_sprite: Sprite2D = $Sprite2D
@onready var mat: ShaderMaterial	  = $Sprite2D.material as ShaderMaterial

# -------------------------------------------------------------------
# Ready Scene
# -------------------------------------------------------------------
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
		pass


# -------------------------------------------------------------------
# Hover events
# -------------------------------------------------------------------
func _on_mouse_entered() -> void:
	# Trigger hover outline
	if mat:
		mat.set_shader_parameter("OnHoverShader", true)


func _on_mouse_exited() -> void:
	# Remove hover outline
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)
