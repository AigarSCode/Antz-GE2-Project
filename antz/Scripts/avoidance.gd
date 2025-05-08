class_name Avoidance extends State


func enter(ant: CharacterBody3D) -> void:
	super.enter(ant)


func exit() -> void:
	pass


func process(delta: float) -> void:
	#(avoidance_force, strength)
	var avoidanceForces: Array = get_avoidance_force()
	if avoidanceForces[1] < 0.05:  # Switch back to Wander if no obstacle
		ant.change_state(ant.get_node("States/Wander"))
		return
	
	# Apply avoidance force directly
	apply_movement(avoidanceForces[0], delta)


func get_avoidance_force() -> Array:
	var avoidance_force = Vector3.ZERO
	var base_feeler_length = 2.0
	var feeler_length = base_feeler_length + ant.velocity.length() * 2.0
	var feeler_angle = deg_to_rad(30)
	var strength = 0.0
	
	var main_direction = ant.velocity.normalized() if ant.velocity.length() > 0.01 else -ant.global_transform.basis.z
	var feeler_dirs = [
		main_direction,
		main_direction.rotated(Vector3.UP, feeler_angle),
		main_direction.rotated(Vector3.UP, -feeler_angle)
	]
	
	var space_state = ant.get_world_3d().direct_space_state
	var hit_distances = [feeler_length, feeler_length, feeler_length]
	var closest_hit_distance = feeler_length
	var closest_hit_index = -1
	
	for i in range(3):
		var from = ant.global_transform.origin
		var to = from + feeler_dirs[i] * feeler_length
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [ant]
		var result = space_state.intersect_ray(query)
		
		var line_color = Color.RED if result else Color.GREEN
		DebugDraw3D.draw_line(from, result.position if result else to, line_color)
		
		if result:
			var distance = (result.position - from).length()
			hit_distances[i] = distance
			if distance < closest_hit_distance:
				closest_hit_distance = distance
				closest_hit_index = i
	
	if closest_hit_index >= 0:
		var left_clearance = hit_distances[2]
		var right_clearance = hit_distances[1]
		var avoidance_dir = ant.global_transform.basis.x if right_clearance > left_clearance else -ant.global_transform.basis.x
		strength = clamp((feeler_length - closest_hit_distance) / feeler_length, 0.0, 1.0)
		avoidance_force = avoidance_dir * strength * 75
		
		if avoidance_force.length() > 0.01:
			DebugDraw3D.draw_arrow(ant.global_transform.origin, ant.global_transform.origin + avoidance_force.normalized() * 2.0, Color.PURPLE, 0.1)
	
	return [avoidance_force, strength]
