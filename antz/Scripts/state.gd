class_name State extends Node

var ant:CharacterBody3D


func enter(ant: CharacterBody3D) -> void:
	self.ant = ant

func exit() -> void:
	pass

func process(delta: float) -> void:
	pass

func seek(target_pos: Vector3) -> Vector3:
	# Calculate desired velocity (direction to target scaled by speed)
	var to_target = target_pos - ant.global_transform.origin
	var distance = to_target.length()
	
	# Arrival behavior: scale speed based on distance
	var desired_speed = ant.max_speed
	if distance < ant.arrival_distance:
		desired_speed = ant.max_speed * (distance / ant.arrival_distance) # Slow down near target
	
	var desired_velocity = to_target.normalized() * desired_speed
	
	# Calculate steering force (desired velocity - current velocity)
	var steering = desired_velocity - ant.velocity
	
	# Clamp steering force
	return steering.clamp(Vector3(-ant.max_force, -ant.max_force, -ant.max_force), 
						 Vector3(ant.max_force, ant.max_force, ant.max_force))


func apply_movement(steering_force: Vector3, delta: float) -> void:
	# Add avoidance steering to the state's steering force
	var avoidance_steering = get_avoidance_steering()
	# Prioritize avoidance when close to obstacle
	var avoidance_weight = 1.0 if avoidance_steering.length() > 0.01 else 0.0
	var total_steering = steering_force * (1.0 - avoidance_weight * 0.7) + avoidance_steering
	
	var acceleration = steering_force.clamp(Vector3(-ant.max_acceleration, -ant.max_acceleration, -ant.max_acceleration), 
											Vector3(ant.max_acceleration, ant.max_acceleration, ant.max_acceleration))
	ant.velocity += acceleration * delta
	#ant.velocity += -ant.velocity * ant.drag_coefficient * delta
	ant.velocity = ant.velocity.limit_length(ant.max_speed)
	ant.velocity.y = 0
	
	if ant.velocity.length_squared() > 0.01:
		var direction = ant.velocity.normalized()
		var target_rotation = atan2(direction.x, direction.z)
		var current_rotation = ant.rotation.y
		var rotation_speed = 7.5
		ant.rotation.y = lerp_angle(current_rotation, target_rotation, rotation_speed * delta)
	
	ant.set_velocity(ant.velocity)
	ant.move_and_slide()
	draw_gizmos(steering_force, acceleration)


func get_avoidance_steering() -> Vector3:
	var avoidance_force = Vector3.ZERO
	var base_feeler_length = 5.0
	var feeler_length = base_feeler_length + ant.velocity.length()
	var feeler_angle = deg_to_rad(30) # Angle for side feelers
	
	# Main direction: use velocity if moving, else facing direction
	var main_direction = ant.velocity.normalized() if ant.velocity.length() > 0.01 else -ant.global_transform.basis.z
	
	# Define feeler directions
	var feeler_dirs = [
		main_direction,
		main_direction.rotated(Vector3.UP, feeler_angle), # Left
		main_direction.rotated(Vector3.UP, -feeler_angle) # Right
	]
	
	# Get the physics space for raycasting
	var space_state = ant.get_world_3d().direct_space_state
	
	var hit_distances = [feeler_length, feeler_length, feeler_length] # Default to max length if no hit
	var closest_hit_distance = feeler_length
	var closest_hit_index = -1
	
	# Cast rays for each feeler
	for i in range(3):
		var from = ant.global_transform.origin
		var to = from + feeler_dirs[i] * feeler_length
		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.exclude = [ant] # Don’t collide with the ant itself
		var result = space_state.intersect_ray(query)
		
		# Draw debug line for the feeler
		var line_color = Color.RED if result else Color.GREEN
		DebugDraw3D.draw_line(from, result.position if result else to, line_color)
		
		if result:
			# Obstacle detected; calculate avoidance strength based on distance
			var distance = (result.position - from).length()
			hit_distances[i] = distance
			if distance < closest_hit_distance:
				closest_hit_distance = distance
				closest_hit_index = i
	
	if closest_hit_index >= 0:
		# Choose avoidance direction based on which side has more clearance
		var left_clearance = hit_distances[2] # Right feeler (steer left)
		var right_clearance = hit_distances[1] # Left feeler (steer right)
		var avoidance_dir = ant.global_transform.basis.x if right_clearance > left_clearance else -ant.global_transform.basis.x
		
		# Scale strength by proximity (closer = stronger)
		var strength = (feeler_length - closest_hit_distance) / feeler_length
		# Stronger avoidance force, especially when close
		avoidance_force = avoidance_dir * strength * 50
		
		# Draw avoidance force for debugging
		if avoidance_force.length() > 0.01:
			DebugDraw3D.draw_arrow(ant.global_transform.origin, ant.global_transform.origin + avoidance_force.normalized() * 2.0, Color.PURPLE, 0.1)
	
	return avoidance_force


func draw_gizmos(steering_force: Vector3, acceleration: Vector3) -> void:
	var arrow_length = 2.0
	
	# Draw desired direction (blue)
	if ant.target:
		var direction = (ant.target.global_transform.origin - ant.global_transform.origin).normalized()
		var direction_end = ant.global_transform.origin + direction * arrow_length
		DebugDraw3D.draw_arrow(ant.global_transform.origin, direction_end, Color.BLUE, 0.1)
	
	# Draw velocity (red)
	var velocity_end = ant.global_transform.origin + ant.velocity.normalized() * arrow_length
	DebugDraw3D.draw_arrow(ant.global_transform.origin, velocity_end, Color.RED, 0.1)
	
	# Draw acceleration (yellow)
	var accel_end = ant.global_transform.origin + acceleration.normalized() * arrow_length
	DebugDraw3D.draw_arrow(ant.global_transform.origin, accel_end, Color.YELLOW, 0.1)
