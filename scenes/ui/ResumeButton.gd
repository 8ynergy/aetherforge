extends Button

func _ready():
	pressed.connect(_on_resume_pressed)

func _on_resume_pressed():
	# Find the PauseMenu parent and emit its signal
	var pause_menu = get_node("../..")
	if pause_menu and pause_menu.has_signal("resume_requested"):
		pause_menu.resume_requested.emit()
