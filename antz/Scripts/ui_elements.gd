extends CanvasLayer

var label_state
var label_speed
var ant

func _ready() -> void:
	label_state = $Control/MarginContainer/VBoxContainer/Label_state
	label_speed = $Control/MarginContainer/VBoxContainer/Label_speed
	ant = $"../Ant"

func _process(delta: float) -> void:
	if ant.current_state is Wander:
		label_state.set_text("Current State: Wander")
	
	label_speed.set_text("Current Speed: " + str(ant.velocity.length()))
