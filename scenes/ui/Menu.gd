extends Control

signal resume_requested
signal quit_to_main_menu_requested

func _ready():
	visible = false
	add_to_group("menu")
	
	# Connect button signals directly
	var resume_btn = get_node("MarginContainer/VBoxContainer/ResumeButton")
	var quit_btn = get_node("MarginContainer/VBoxContainer/QuitToMainMenuButton")
	
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	if quit_btn:
		quit_btn.pressed.connect(_on_quit_pressed)

func show_menu():
	visible = true

func hide_menu():
	visible = false

func toggle_menu():
	if visible:
		hide_menu()
	else:
		show_menu()

func _on_resume_pressed():
	hide_menu()
	resume_requested.emit()

func _on_quit_pressed():
	quit_to_main_menu_requested.emit()
