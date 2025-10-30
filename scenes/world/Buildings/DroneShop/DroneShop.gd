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
		_open_shop_menu()


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

func _open_shop_menu():
	"""Open the drone shop menu"""
	var shop_menu_scene = preload("res://scenes/ui/ShopMenu.tscn")
	var shop_menu = shop_menu_scene.instantiate()
	
	# Add to UI layer
	var ui_root = get_tree().current_scene.get_node("UIRoot")
	ui_root.add_child(shop_menu)
	
	# Show the menu
	shop_menu.show_menu("DroneShop")
	
	# Connect close signal to remove from scene
	shop_menu.menu_closed.connect(_on_shop_menu_closed.bind(shop_menu))

func _on_shop_menu_closed(menu_instance):
	"""Handle shop menu closing"""
	if menu_instance and is_instance_valid(menu_instance):
		menu_instance.queue_free()
