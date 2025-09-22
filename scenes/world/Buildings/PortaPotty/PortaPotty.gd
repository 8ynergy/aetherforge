extends Area2D

enum State { CLOSED, OPENING, OPENED, CLOSING }

@onready var static_sprite: Sprite2D = $Sprite2D
@onready var anim: AnimatedSprite2D   = $AnimatedSprite2D
@onready var mat: ShaderMaterial	  = $Sprite2D.material as ShaderMaterial

# Preload textures directly from your given paths
@onready var closed_texture: Texture2D = preload("res://scenes/world/Buildings/PortaPotty/PortaPotty.png")
@onready var opened_texture: Texture2D = preload("res://scenes/world/Buildings/PortaPotty/PortaPottyOpened.png")

var state: State = State.CLOSED
var want_open_after: bool = false
var want_close_after: bool = false

func _ready() -> void:
	# Start with the closed texture visible
	static_sprite.texture = closed_texture
	static_sprite.show()
	anim.hide()

	# Safety check for shader material
	if mat == null:
		push_warning("No ShaderMaterial assigned; hover outline won't appear.")

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		
		# Get the current scene's filename
		var current_scene = get_tree().current_scene.scene_file_path.get_file()
		
		if current_scene == "Main.tscn":
			# var target_scene_path = "res://scenes/main/Camp.tscn"
			
			# Goes to the next scene
			# get_tree().change_scene_to_file(target_scene_path)
			
			# Remove white outline
			if mat:
				mat.set_shader_parameter("OnHoverShader", false)
		
		if current_scene == "Camp.tscn":
			# var target_scene_path = "res://scenes/main/Main.tscn"
			
			#Goes to next scene
			# get_tree().change_scene_to_file(target_scene_path)
			
			# Remove white outline
			if mat:
				mat.set_shader_parameter("OnHoverShader", false)

# -------------------------------------------------------------------
# Hover events
# -------------------------------------------------------------------
func _on_mouse_entered() -> void:
	want_open_after = true
	want_close_after = false

	# Trigger hover outline
	if mat:
		mat.set_shader_parameter("OnHoverShader", true)

	# Handle opening
	match state:
		State.CLOSED:
			_play_open()
		State.CLOSING:
			want_open_after = true
			want_close_after = false
		State.OPENING:
			want_open_after = false
			want_close_after = true
		_:
			pass

func _on_mouse_exited() -> void:
	want_open_after = false
	want_close_after = true
	# Remove hover outline
	if mat:
		mat.set_shader_parameter("OnHoverShader", false)

	# Handle closing
	match state:
		State.OPENED:
			_play_close()
		State.OPENING:
			want_open_after = false
			want_close_after = true
		State.CLOSING:
			want_open_after = true
			want_close_after = false
		_:
			pass

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------
func _play_open() -> void:
	state = State.OPENING
	static_sprite.hide()
	anim.show()
	anim.play("Open")

func _play_close() -> void:
	state = State.CLOSING
	static_sprite.hide()
	anim.show()
	anim.play("Close")


# -------------------------------------------------------------------
# Animation finished
# -------------------------------------------------------------------
func _on_animated_sprite_2d_animation_finished() -> void:
	match String(anim.animation):
		"Open":
			state = State.OPENED
			anim.hide()
			static_sprite.texture = opened_texture
			static_sprite.position.y += 16
			static_sprite.show()

			# Force y-sort recalculation
			static_sprite.get_parent().y_sort_enabled = false
			static_sprite.get_parent().y_sort_enabled = true
			
			if want_close_after == true:
				_play_close()

		"Close":
			state = State.CLOSED
			anim.hide()
			static_sprite.texture = closed_texture
			static_sprite.position.y -= 16
			static_sprite.show()

			# Force y-sort recalculation
			static_sprite.get_parent().y_sort_enabled = false
			static_sprite.get_parent().y_sort_enabled = true
