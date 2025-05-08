class_name State extends Node

var ant:CharacterBody3D

func enter(ant: CharacterBody3D) -> void:
	self.ant = ant

func exit() -> void:
	pass

func _process(delta: float) -> void:
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
	var acceleration = steering_force.clamp(Vector3(-ant.max_acceleration, -ant.max_acceleration, -ant.max_acceleration), 
											Vector3(ant.max_acceleration, ant.max_acceleration, ant.max_acceleration))
	ant.velocity += acceleration * delta
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
	if ant.gizmos_enabled:
		draw_gizmos(steering_force, acceleration)


func draw_gizmos(steering_force: Vector3, acceleration: Vector3) -> void:
	var arrow_length = 2.0
	
	# Draw velocity (red)
	var velocity_end = ant.global_transform.origin + ant.velocity.normalized() * arrow_length
	DebugDraw3D.draw_arrow(ant.global_transform.origin, velocity_end, Color.RED, 0.1)
	
	# Draw acceleration (yellow)
	var accel_end = ant.global_transform.origin + acceleration.normalized() * arrow_length
	DebugDraw3D.draw_arrow(ant.global_transform.origin, accel_end, Color.YELLOW, 0.1)
