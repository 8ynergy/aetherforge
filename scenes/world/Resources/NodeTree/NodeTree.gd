extends Area2D

@onready var static_sprite: Sprite2D = $Sprite2D
@onready var anim: AnimatedSprite2D   = $AnimatedSprite2D
@onready var animLeaves: AnimatedSprite2D   = $AnimatedSprite2DLeaves
@onready var mat: ShaderMaterial	  = $Sprite2D.material as ShaderMaterial
@onready var matanim: ShaderMaterial	  = $AnimatedSprite2D.material as ShaderMaterial

# Preload textures directly from your given paths
@onready var static_texture: Texture2D = preload("res://scenes/world/Resources/NodeTree/NodeTreeEmpty.png")


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
	
	var original_mat_anim = $AnimatedSprite2D.material as ShaderMaterial
	if original_mat_anim:
		matanim = original_mat_anim.duplicate()
		$AnimatedSprite2D.material = matanim
	else:
		push_warning("No ShaderMaterial assigned for anim; hover outline won't appear.")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		_play_empty_shake()


# -------------------------------------------------------------------
# Hover events
# -------------------------------------------------------------------
func _on_mouse_entered() -> void:
	# Trigger hover outline
	if matanim:
		matanim.set_shader_parameter("OnHoverShader", true)

	_play_empty_hover()

func _on_mouse_exited() -> void:
	# Remove hover outline
	if matanim:
		matanim.set_shader_parameter("OnHoverShader", false)

	pass

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------
func _play_empty_hover() -> void:
	# static_sprite.hide()
	anim.show()
	anim.play("EmptyHover")
	animLeaves.show()
	animLeaves.play("EmptyHoverLeaves")
	
func _play_empty_shake() -> void:
	# static_sprite.hide()
	anim.show()
	anim.play("EmptyShake")
	animLeaves.show()
	animLeaves.play("EmptyShakeLeaves")

# -------------------------------------------------------------------
# Animation finished
# -------------------------------------------------------------------
func _on_animated_sprite_2d_animation_finished() -> void:
	match String(anim.animation):
		"EmptyHover":
			pass

		"EmptyShake":
			pass
			

func _on_animated_sprite_2d_leaves_animation_finished() -> void:
	match String(animLeaves.animation):
		"EmptyHoverLeaves":
			animLeaves.hide()
		
		"EmptyShakeLeaves":
			animLeaves.hide()
