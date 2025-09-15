extends Control

signal resume_requested
signal quit_to_main_menu_requested

func _ready():
	visible = false
	add_to_group("pause_menu")
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Connect button signals directly
	var resume_btn = get_node("MarginContainer/VBoxContainer/ResumeButton")
	var quit_btn = get_node("MarginContainer/VBoxContainer/QuitToMainMenuButton")
	
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

func show_pause_menu():
	visible = true
	get_tree().paused = true

func hide_pause_menu():
	visible = false
	get_tree().paused = false

func toggle_pause_menu():
	if visible:
		hide_pause_menu()
	else:
		show_pause_menu()

func _on_resume_pressed():
	hide_pause_menu()
	resume_requested.emit()

func _on_quit_pressed():
	quit_to_main_menu_requested.emit()
