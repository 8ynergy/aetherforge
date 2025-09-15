extends Button

func _ready():
	pressed.connect(_on_load_pressed)

func _on_load_pressed():
	var saver = get_tree().root.find_child("SaveSys", true, false)
	if saver: 
		saver.load_game()
		print("Game loaded!")
