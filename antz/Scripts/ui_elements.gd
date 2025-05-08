extends CanvasLayer

@onready var label_state = $Control/InfoBox/VBoxContainer/Label_state
@onready var label_speed = $Control/InfoBox/VBoxContainer/Label_speed
@onready var label_target = $Control/InfoBox/VBoxContainer/Label_target

# Settings Controls
@onready var config_box = $Control/ConfigBox
@onready var max_speed_slider = $Control/ConfigBox/VBoxContainer/HBoxContainer/HSlider
@onready var max_speed_val = $Control/ConfigBox/VBoxContainer/HBoxContainer/Label_max_speed_val

@onready var max_force_slider = $Control/ConfigBox/VBoxContainer/HBoxContainer2/HSlider
@onready var max_force_val = $Control/ConfigBox/VBoxContainer/HBoxContainer2/Label_max_force_val

@onready var max_acceleration_slider = $Control/ConfigBox/VBoxContainer/HBoxContainer3/HSlider
@onready var max_acceleration_val = $Control/ConfigBox/VBoxContainer/HBoxContainer3/Label_max_acceleration_val

@onready var gizmos_enabled = $Control/ConfigBox/VBoxContainer/HBoxContainer4/CheckBox
@onready var ui_hidden = $Control/ConfigBox/VBoxContainer/HBoxContainer5/CheckBox2
# Food Found
@onready var food_found_val = $Control/FoodFound/VBoxContainer/Label_FoodFound_Val

var ant

func _ready() -> void:
	ant = $"../Ant"
	config_box.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Connections
	max_speed_slider.connect("value_changed", _max_speed_change)
	max_force_slider.connect("value_changed", _max_force_change)
	max_acceleration_slider.connect("value_changed", _max_acceleration_change)
	gizmos_enabled.connect("toggled", _gizmos_enabled)
	ui_hidden.connect("toggled", _ui_hidden)


# Update all UI elements
func _process(delta: float) -> void:
	if !ui_hidden.button_pressed:
		label_state.set_text("Current State: " + ant.current_state.name)
		if ant.target:
			label_target.set_text("Current Food Target: " + str(ant.target.get_parent().get_parent().name))
		else:
			label_target.set_text("Current Food Target: N/A")
		label_speed.set_text("Current Speed: " + str(ant.velocity.length()))
		food_found_val.set_text(str(ant.food_pickedup))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ESC"):
		config_box.visible = !config_box.visible
		if config_box.visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _max_speed_change(value) -> void:
	if ant:
		ant.max_speed = value
		max_speed_val.set_text(str(value))

func _max_force_change(value) -> void:
	if ant:
		ant.max_force = value
		max_force_val.set_text(str(value))

func _max_acceleration_change(value) -> void:
	if ant:
		ant.max_acceleration = value
		max_acceleration_val.set_text(str(value))

func _gizmos_enabled(button_pressed) -> void:
	ant.gizmos_enabled = button_pressed

func _ui_hidden(button_pressed) -> void:
	$Control/InfoBox.visible = !$Control/InfoBox.visible
	$Control/Keybinds.visible = !$Control/Keybinds.visible
	$Control/FoodFound.visible = !$Control/FoodFound.visible
