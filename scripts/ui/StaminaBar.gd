extends Control

# Stamina bar UI component
# Displays current stamina and handles visual feedback

func _init():
	print("StaminaBar: _init() called")

@onready var stamina_bar: ProgressBar = $MarginContainer/VBoxContainer/StaminaProgressBar
@onready var stamina_label: Label = $MarginContainer/VBoxContainer/StaminaLabel

var is_low_stamina: bool = false
var is_restoring: bool = false
var low_stamina_threshold: float = 0.2  # 20% of max stamina

func _ready() -> void:
	# Wait for the next frame to ensure singletons are loaded
	print("StaminaBar: _ready() called")
	print("StaminaBar: stamina_bar reference: ", stamina_bar)
	print("StaminaBar: stamina_label reference: ", stamina_label)
	call_deferred("_connect_to_stamina")

func _connect_to_stamina() -> void:
	print("StaminaBar: _connect_to_stamina() called")
	
	# Debug: List all children to see the actual node structure
	print("StaminaBar: Root node children:")
	for child in get_children():
		print("  - ", child.name, " (", child.get_class(), ")")
	
	# Try to find nodes step by step
	if has_node("MarginContainer"):
		print("StaminaBar: Found MarginContainer")
		var margin = get_node("MarginContainer")
		print("StaminaBar: MarginContainer children:")
		for child in margin.get_children():
			print("  - ", child.name, " (", child.get_class(), ")")
		
		if margin.has_node("VBoxContainer"):
			print("StaminaBar: Found VBoxContainer")
			var vbox = margin.get_node("VBoxContainer")
			print("StaminaBar: VBoxContainer children:")
			for child in vbox.get_children():
				print("  - ", child.name, " (", child.get_class(), ")")
	
	# Get node references manually since @onready might not be working
	stamina_bar = get_node("MarginContainer/VBoxContainer/StaminaProgressBar")
	stamina_label = get_node("MarginContainer/VBoxContainer/StaminaLabel")
	
	print("StaminaBar: Manually getting node references")
	print("StaminaBar: stamina_bar reference: ", stamina_bar)
	print("StaminaBar: stamina_label reference: ", stamina_label)
	
	# Connect to stamina singleton signals
	# Try multiple approaches to get the stamina singleton
	var stamina_singleton = null
	
	# First try the global singleton
	if Stamina:
		stamina_singleton = Stamina
		print("StaminaBar: Found Stamina singleton via global reference")
	# Then try via get_node
	elif has_node("/root/Stamina"):
		stamina_singleton = get_node("/root/Stamina")
		print("StaminaBar: Found Stamina singleton via get_node")
	
	if stamina_singleton:
		print("StaminaBar: Connecting to Stamina singleton")
		stamina_singleton.stamina_changed.connect(_on_stamina_changed)
		stamina_singleton.stamina_depleted.connect(_on_stamina_depleted)
		stamina_singleton.stamina_restored.connect(_on_stamina_restored)
		stamina_singleton.restoration_started.connect(_on_restoration_started)
		stamina_singleton.restoration_stopped.connect(_on_restoration_stopped)
		
		# Check if signals are connected
		print("StaminaBar: Signal connections - stamina_changed: ", stamina_singleton.stamina_changed.get_connections().size())
		
		# Initialize with current stamina
		var current = stamina_singleton.get_current_stamina()
		var max_stamina = stamina_singleton.get_max_stamina()
		print("StaminaBar: Initial stamina values - ", current, "/", max_stamina)
		_update_stamina_display(current, max_stamina)
	else:
		push_warning("Stamina singleton not found!")

func _on_stamina_changed(current: int, max_stamina: int) -> void:
	"""Update stamina bar when stamina changes"""
	# Debug output removed to reduce console spam
	_update_stamina_display(current, max_stamina)

func _on_stamina_depleted() -> void:
	"""Handle stamina depletion"""
	print("Stamina depleted!")
	# Could add visual effects here like screen flash or warning

func _on_stamina_restored() -> void:
	"""Handle stamina fully restored"""
	print("Stamina fully restored!")
	# Could add visual effects here

func _on_restoration_started() -> void:
	"""Handle stamina restoration started"""
	print("Stamina restoration started")
	is_restoring = true
	# Add visual indicator that restoration is active
	if stamina_bar:
		stamina_bar.modulate = Color.CYAN

func _on_restoration_stopped() -> void:
	"""Handle stamina restoration stopped"""
	print("Stamina restoration stopped")
	is_restoring = false
	# Remove restoration visual indicator and set appropriate color
	if stamina_bar:
		# Re-evaluate the color based on current stamina level
		var current = Stamina.get_current_stamina()
		var max_stamina = Stamina.get_max_stamina()
		if current <= max_stamina * low_stamina_threshold:
			stamina_bar.modulate = Color.RED
		else:
			stamina_bar.modulate = Color.WHITE

func _update_stamina_display(current: int, max_stamina: int) -> void:
	"""Update the stamina bar and label display"""
	# Debug output removed to reduce console spam
	if stamina_bar:
		# Set the max_value to match the actual max stamina
		stamina_bar.max_value = max_stamina
		# Set the current value directly (not as percentage)
		stamina_bar.value = current
		# Debug output removed to reduce console spam
		
		# Update low stamina state
		is_low_stamina = current <= max_stamina * low_stamina_threshold
		
		# Change color based on stamina level and restoration state
		if is_restoring:
			stamina_bar.modulate = Color.CYAN
		elif is_low_stamina:
			stamina_bar.modulate = Color.RED
		else:
			stamina_bar.modulate = Color.WHITE
	else:
		print("StaminaBar: ERROR - stamina_bar is null!")
	
	if stamina_label:
		stamina_label.text = "Stamina: %d/%d" % [current, max_stamina]
