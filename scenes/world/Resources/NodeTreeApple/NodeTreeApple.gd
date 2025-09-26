extends Area2D

enum State { RIPE, EMPTY }

@onready var static_sprite: Sprite2D = $Sprite2D
@onready var anim: AnimatedSprite2D   = $AnimatedSprite2D
@onready var animLeaves: AnimatedSprite2D   = $AnimatedSprite2DLeaves
@onready var mat: ShaderMaterial	  = $Sprite2D.material as ShaderMaterial
@onready var matanim: ShaderMaterial	  = $AnimatedSprite2D.material as ShaderMaterial

var state: State = State.RIPE

# Preload textures directly from your given paths
# @onready var static_texture: Texture2D = preload("res://scenes/world/Resources/NodeTreeApple/NodeTreeAppleEmpty.png")
# @onready var static_apple_texture: Texture2D = preload("res://scenes/world/Resources/NodeTreeApple/NodeTreeAppleRipe.png")


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

	match state:
		State.RIPE:
			anim.animation = "RipeHover"
		State.EMPTY:
			anim.animation = "EmptyHover"
		_:
			pass


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if state == State.RIPE:
				_play_ripe_shake()

		if state == State.EMPTY:
				_play_empty_shake()


# -------------------------------------------------------------------
# Hover events
# -------------------------------------------------------------------
func _on_mouse_entered() -> void:
	# Trigger hover outline
	if matanim:
		matanim.set_shader_parameter("OnHoverShader", true)

		match state:
			State.RIPE:
				_play_ripe_hover()
			State.EMPTY:
				_play_empty_hover()
			_:
				pass

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
	animLeaves.play("HoverLeaves")
	
func _play_empty_shake() -> void:
	# static_sprite.hide()
	anim.show()
	anim.play("EmptyShake")
	animLeaves.show()
	animLeaves.play("ShakeLeaves")

func _play_ripe_hover() -> void:
	# static_sprite.hide()
	anim.show()
	anim.play("RipeHover")
	animLeaves.show()
	animLeaves.play("HoverLeaves")

func _play_ripe_shake() -> void:
	# static_sprite.hide()
	anim.show()
	anim.play("RipeShake")
	animLeaves.show()
	animLeaves.play("ShakeLeaves")
	state = State.EMPTY

# -------------------------------------------------------------------
# Animation finished
# -------------------------------------------------------------------
func _on_animated_sprite_2d_animation_finished() -> void:
	match String(anim.animation):
		"RipeShake":
			anim.animation = "EmptyHover"

		"EmptyShake":
			pass
			

func _on_animated_sprite_2d_leaves_animation_finished() -> void:
	match String(animLeaves.animation):
		"HoverLeaves":
			animLeaves.hide()
		
		"ShakeLeaves":
			animLeaves.hide()
