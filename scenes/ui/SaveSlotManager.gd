extends Control

# Signals for communication with parent scenes
signal slot_selected(slot_number: int)
signal back_pressed

# Mode: "save", "load", or "new_game"
var mode: String = "save"
var slot_buttons: Array[Button] = []
var current_confirmation_dialog: Control = null

func _ready() -> void:
	# Get all slot buttons
	slot_buttons = [
		$CenterContainer/VBoxContainer/SlotGrid/Slot1,
		$CenterContainer/VBoxContainer/SlotGrid/Slot2,
		$CenterContainer/VBoxContainer/SlotGrid/Slot3,
		$CenterContainer/VBoxContainer/SlotGrid/Slot4,
		$CenterContainer/VBoxContainer/SlotGrid/Slot5
	]
	
	# Connect slot button signals
	for i in range(slot_buttons.size()):
		slot_buttons[i].pressed.connect(_on_slot_button_pressed.bind(i + 1))
	
	# Connect back button
	$CenterContainer/VBoxContainer/ButtonContainer/BackButton.pressed.connect(_on_back_pressed)
	
	# Connect background click to close dialog
	$Background.gui_input.connect(_on_background_clicked)
	
	# Update slot display
	_update_slot_display()

func set_mode(new_mode: String) -> void:
	"""Set the mode: 'save', 'load', or 'new_game'"""
	mode = new_mode
	_update_title()
	_update_slot_display()

func _update_title() -> void:
	"""Update the title based on mode"""
	match mode:
		"save":
			$CenterContainer/VBoxContainer/TitleLabel.text = "Select Save Slot"
		"load":
			$CenterContainer/VBoxContainer/TitleLabel.text = "Select Load Slot"
		"new_game":
			$CenterContainer/VBoxContainer/TitleLabel.text = "Select New Game Slot"

func _update_slot_display() -> void:
	"""Update the display of all save slots"""
	var all_slots = Global.get_all_slot_info()
	
	for i in range(slot_buttons.size()):
		var slot_info = all_slots[i]
		var button = slot_buttons[i]
		
		if slot_info.get("empty", true):
			button.text = "Slot " + str(i + 1) + " - Empty"
			# For save and new_game modes, all slots should be enabled (including empty ones)
			# For load mode, empty slots should be disabled
			button.disabled = (mode == "load")
		else:
			var timestamp = slot_info.get(SaveSettings.METADATA_KEYS.timestamp, "Unknown")
			var level = slot_info.get(SaveSettings.METADATA_KEYS.level, "Unknown")
			var playtime = slot_info.get(SaveSettings.METADATA_KEYS.playtime, 0)
			
			# Format timestamp to local time
			var formatted_timestamp = _format_timestamp(timestamp)
			
			# Format playtime (ensure playtime is an integer for modulo operation)
			var playtime_int = int(playtime)
			var hours = int(playtime_int / 3600)
			var minutes = int((playtime_int % 3600) / 60)
			var time_str = ""
			if hours > 0:
				time_str = str(int(hours)) + "h " + str(int(minutes)) + "m"
			else:
				time_str = str(int(minutes)) + "m"
			
			# Display slot info without inline warnings (popups will handle confirmations)
			button.text = "Slot " + str(i + 1) + " - " + level + "\n" + formatted_timestamp + " (" + time_str + ")"
			
			# All non-empty slots should be enabled for save, load, and new_game modes
			button.disabled = false

func _on_slot_button_pressed(slot_number: int) -> void:
	"""Handle slot button press"""
	# Check if we need to show a confirmation dialog
	var slot_info = Global.get_slot_info(slot_number)
	var is_empty = slot_info.get("empty", true)
	
	# Show confirmation for overwriting existing saves
	if not is_empty and (mode == "save" or mode == "new_game"):
		_show_overwrite_confirmation(slot_number, slot_info)
	else:
		# No confirmation needed, proceed directly
		slot_selected.emit(slot_number)

func _show_overwrite_confirmation(slot_number: int, slot_info: Dictionary) -> void:
	"""Show confirmation dialog for overwriting existing save"""
	# Hide the SaveSlotSelector content and background while showing confirmation dialog
	$CenterContainer.visible = false
	$Background.visible = false
	
	current_confirmation_dialog = preload("res://scenes/ui/ConfirmationDialog.tscn").instantiate()
	# Add to the same parent as this SaveSlotSelector to maintain proper UI hierarchy
	get_parent().add_child(current_confirmation_dialog)
	
	var title = ""
	var message = ""
	
	if mode == "new_game":
		title = "Overwrite Save Slot?"
		var timestamp = slot_info.get(SaveSettings.METADATA_KEYS.timestamp, "Unknown")
		var formatted_timestamp = _format_timestamp(timestamp)
		message = "Slot " + str(slot_number) + " contains an existing save.\n\n" + \
				 "Level: " + slot_info.get(SaveSettings.METADATA_KEYS.level, "Unknown") + "\n" + \
				 "Date: " + formatted_timestamp + "\n\n" + \
				 "Starting a new game will permanently overwrite this save.\n\n" + \
				 "Are you sure you want to continue?" + \
				 " "
	else:  # mode == "save"
		title = "Overwrite Save Slot?"
		var timestamp = slot_info.get(SaveSettings.METADATA_KEYS.timestamp, "Unknown")
		var formatted_timestamp = _format_timestamp(timestamp)
		message = "Slot " + str(slot_number) + " contains an existing save.\n\n" + \
				 "Level: " + slot_info.get(SaveSettings.METADATA_KEYS.level, "Unknown") + "\n" + \
				 "Date: " + formatted_timestamp + "\n\n" + \
				 "Saving will permanently overwrite this save.\n\n" + \
				 "Are you sure you want to continue?" + \
				 " "
	
	current_confirmation_dialog.show_confirmation(title, message, slot_number, mode)
	current_confirmation_dialog.confirmed.connect(_on_confirmation_confirmed)
	current_confirmation_dialog.cancelled.connect(_on_confirmation_cancelled)

func _on_confirmation_confirmed(slot_number: int, _mode: String) -> void:
	"""Handle confirmation dialog confirmed"""
	print("SaveSlotManager: Confirmation confirmed for slot ", slot_number)
	
	# Clean up confirmation dialog
	if current_confirmation_dialog:
		print("SaveSlotManager: Cleaning up confirmation dialog")
		# Disconnect signals to prevent double-cleanup
		if current_confirmation_dialog.confirmed.is_connected(_on_confirmation_confirmed):
			current_confirmation_dialog.confirmed.disconnect(_on_confirmation_confirmed)
		if current_confirmation_dialog.cancelled.is_connected(_on_confirmation_cancelled):
			current_confirmation_dialog.cancelled.disconnect(_on_confirmation_cancelled)
		current_confirmation_dialog.queue_free()
		current_confirmation_dialog = null
	
	# Restore SaveSlotSelector so SaveButton can find and remove it
	$CenterContainer.visible = true
	$Background.visible = true
	print("SaveSlotManager: Restored SaveSlotSelector visibility")
	
	# Emit signal to trigger save
	print("SaveSlotManager: Emitting slot_selected signal")
	slot_selected.emit(slot_number)

func _on_confirmation_cancelled() -> void:
	"""Handle confirmation dialog cancelled"""
	# Clean up confirmation dialog
	if current_confirmation_dialog:
		# Disconnect signals to prevent double-cleanup
		if current_confirmation_dialog.confirmed.is_connected(_on_confirmation_confirmed):
			current_confirmation_dialog.confirmed.disconnect(_on_confirmation_confirmed)
		if current_confirmation_dialog.cancelled.is_connected(_on_confirmation_cancelled):
			current_confirmation_dialog.cancelled.disconnect(_on_confirmation_cancelled)
		current_confirmation_dialog.queue_free()
		current_confirmation_dialog = null
	
	# Restore SaveSlotSelector content and background
	$CenterContainer.visible = true
	$Background.visible = true

func _on_back_pressed() -> void:
	"""Handle back button press"""
	print("SaveSlotManager: Back button pressed")
	
	# Clean up any existing confirmation dialog
	if current_confirmation_dialog:
		if current_confirmation_dialog.confirmed.is_connected(_on_confirmation_confirmed):
			current_confirmation_dialog.confirmed.disconnect(_on_confirmation_confirmed)
		if current_confirmation_dialog.cancelled.is_connected(_on_confirmation_cancelled):
			current_confirmation_dialog.cancelled.disconnect(_on_confirmation_cancelled)
		current_confirmation_dialog.queue_free()
		current_confirmation_dialog = null
	
	back_pressed.emit()

func _format_timestamp(timestamp_string: String) -> String:
	"""Format timestamp string to readable local date and time"""
	if timestamp_string == "Unknown":
		return "Unknown"
	
	# Parse the timestamp string (format: "2024-01-15T14:30:45")
	var datetime = timestamp_string.split("T")
	if datetime.size() != 2:
		return timestamp_string  # Return original if format is unexpected
	
	var date_parts = datetime[0].split("-")
	var time_parts = datetime[1].split(":")
	
	if date_parts.size() != 3 or time_parts.size() != 3:
		return timestamp_string  # Return original if format is unexpected
	
	# Create a dictionary for the date/time
	var date_dict = {
		"year": int(date_parts[0]),
		"month": int(date_parts[1]),
		"day": int(date_parts[2]),
		"hour": int(time_parts[0]),
		"minute": int(time_parts[1]),
		"second": int(time_parts[2])
	}
	
	# Convert to unix timestamp and then to local time
	var unix_time = Time.get_unix_time_from_datetime_dict(date_dict)
	var local_datetime = Time.get_datetime_dict_from_unix_time(unix_time)
	
	# Format as readable string (e.g., "Jan 15, 2024 2:30 PM")
	var month_names = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", 
					   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
	
	var month_name = month_names[local_datetime.month - 1]
	var hour_12 = local_datetime.hour
	var am_pm = "AM"
	
	# Convert to 12-hour format
	if hour_12 == 0:
		hour_12 = 12
	elif hour_12 > 12:
		hour_12 -= 12
		am_pm = "PM"
	elif hour_12 == 12:
		am_pm = "PM"
	
	# Format with zero-padded minutes
	var minute_str = str(local_datetime.minute).pad_zeros(2)
	
	return "%s %d, %d %d:%s %s" % [month_name, local_datetime.day, local_datetime.year, hour_12, minute_str, am_pm]

func _on_background_clicked(event: InputEvent) -> void:
	"""Handle background click to close dialog"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		back_pressed.emit()
