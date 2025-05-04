extends State


func enter(ant: CharacterBody3D) -> void:
	super.enter(ant)

func exit() -> void:
	pass

func process(delta: float) -> void:
	var target_pos = wander()
	var steering_force = seek(target_pos)
	apply_movement(steering_force, delta)


func wander() -> Vector3:
	var wander_radius = 20.0
	var random_angle = randf_range(0, TAU)
	var offset = Vector3(cos(random_angle), 0, sin(random_angle)) * wander_radius
	return ant.global_transform.origin + offset
