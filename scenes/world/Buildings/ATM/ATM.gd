extends Area2D


@onready var anim: AnimatedSprite2D   = $AnimatedSprite2D
@onready var mat: ShaderMaterial	  = $AnimatedSprite2D.material as ShaderMaterial

# Preload textures directly from your given paths
@onready var opened_texture: Texture2D = preload("res://scenes/world/Buildings/ATM/ATManim.png")


# -------------------------------------------------------------------
# Ready Scene
# -------------------------------------------------------------------
func _ready() -> void:
	# Create a unique material instance for this junk pile
	var original_mat = $AnimatedSprite2D.material as ShaderMaterial
	if original_mat:
		mat = original_mat.duplicate()
		$AnimatedSprite2D.material = mat
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

	_play_open()

func _on_mouse_exited() -> void:
	# Remove hover outline
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)

	_play_idle()

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------
func _play_open() -> void:
	anim.show()
	anim.play("Open")

func _play_idle() -> void:
	anim.show()
	anim.play("Idle")
