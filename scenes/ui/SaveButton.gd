extends Button

func _ready():
	pressed.connect(_on_save_pressed)

func _on_save_pressed():
	var saver = get_tree().root.find_child("SaveSys", true, false)
	if saver: 
		saver.save_game()
		print("Game saved!")
