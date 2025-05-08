extends State


func enter(ant: CharacterBody3D) -> void:
	super.enter(ant)


func exit() -> void:
	pass


func process(delta: float) -> void:
	var dist = (ant.global_position - ant.target.global_position).length()
	if dist < 1:
		pickup_food()
	else:
		var steering_force = seek(ant.target.global_position)
		apply_movement(steering_force, delta)


func pickup_food() -> void:
	# Remove the food from the world
	ant.target.get_parent().get_parent().queue_free()
	
	# Set state back to wander
	ant.change_state(ant.get_node("States/Wander"))
