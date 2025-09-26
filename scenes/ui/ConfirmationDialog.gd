extends Control

# Signals for communication
signal confirmed(slot_number: int, mode: String)
signal cancelled

var _original_slot_number: int = 0
var _original_mode: String = ""

func _ready() -> void:
	# Connect button signals using get_node with the exact node names
	get_node("CenterContainer/DialogBox/MarginContainer/VBoxContainer/CenterContainer_DialogBox_VBoxContainer#ButtonContainer/CenterContainer_DialogBox_VBoxContainer_ButtonContainer#CancelButton").pressed.connect(_on_cancel_pressed)
	get_node("CenterContainer/DialogBox/MarginContainer/VBoxContainer/CenterContainer_DialogBox_VBoxContainer#ButtonContainer/CenterContainer_DialogBox_VBoxContainer_ButtonContainer#ConfirmButton").pressed.connect(_on_confirm_pressed)
	
	# Connect background click to cancel
	$Background.gui_input.connect(_on_background_clicked)

func show_confirmation(title: String, message: String, slot_number: int = 0, mode: String = "") -> void:
	"""Show confirmation dialog with custom title and message"""
	_original_slot_number = slot_number
	_original_mode = mode
	
	get_node("CenterContainer/DialogBox/MarginContainer/VBoxContainer/CenterContainer_DialogBox_VBoxContainer#TitleLabel").text = title
	get_node("CenterContainer/DialogBox/MarginContainer/VBoxContainer/CenterContainer_DialogBox_VBoxContainer#MessageLabel").text = message
	
	# Ensure proper positioning and visibility
	visible = true
	# Force the dialog to be on top and properly positioned
	move_to_front()
	# Ensure the dialog is properly sized and positioned
	call_deferred("_ensure_proper_positioning")

func _on_confirm_pressed() -> void:
	"""Handle confirm button press"""
	confirmed.emit(_original_slot_number, _original_mode)
	queue_free()

func _on_cancel_pressed() -> void:
	"""Handle cancel button press"""
	cancelled.emit()
	queue_free()

func _on_background_clicked(event: InputEvent) -> void:
	"""Handle background click to cancel"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cancelled.emit()
		queue_free()

func _ensure_proper_positioning() -> void:
	"""Ensure the dialog is properly positioned and sized"""
	# Force the dialog to fill the entire screen properly
	anchors_preset = Control.PRESET_FULL_RECT
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0
	offset_top = 0
	offset_right = 0
	offset_bottom = 0
	
	# Ensure the background covers the full area
	$Background.anchors_preset = Control.PRESET_FULL_RECT
	$Background.anchor_right = 1.0
	$Background.anchor_bottom = 1.0
	$Background.offset_left = 0
	$Background.offset_top = 0
	$Background.offset_right = 0
	$Background.offset_bottom = 0
	
	# Ensure the center container is properly positioned
	$CenterContainer.anchors_preset = Control.PRESET_FULL_RECT
	$CenterContainer.anchor_right = 1.0
	$CenterContainer.anchor_bottom = 1.0
	$CenterContainer.offset_left = 0
	$CenterContainer.offset_top = 0
	$CenterContainer.offset_right = 0
	$CenterContainer.offset_bottom = 0
	
	# Ensure the dialog is interactive and on top
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Background.process_mode = Node.PROCESS_MODE_ALWAYS
	$CenterContainer.process_mode = Node.PROCESS_MODE_ALWAYS
