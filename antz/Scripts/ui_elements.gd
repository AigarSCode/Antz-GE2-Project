extends CanvasLayer

var label_state
var label_speed
var label_target
var ant

func _ready() -> void:
	label_state = $Control/MarginContainer/VBoxContainer/Label_state
	label_target= $Control/MarginContainer/VBoxContainer/Label_target
	label_speed = $Control/MarginContainer/VBoxContainer/Label_speed
	ant = $"../Ant"

func _process(delta: float) -> void:
	label_state.set_text("Current State: " + ant.current_state.name)
	if ant.target:
		label_target.set_text("Current Food Target: " + str(ant.target.get_parent().get_parent().name))
	else:
		label_target.set_text("Current Food Target: N/A")
	label_speed.set_text("Current Speed: " + str(ant.velocity.length()))
