extends Button

func _ready():
	pressed.connect(_on_quit_pressed)

func _on_quit_pressed():
	# Find the PauseMenu parent and emit its signal
	var pause_menu = get_node("../..")
	if pause_menu and pause_menu.has_signal("quit_to_main_menu_requested"):
		pause_menu.quit_to_main_menu_requested.emit()
