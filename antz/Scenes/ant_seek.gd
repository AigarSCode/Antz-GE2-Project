extends CharacterBody3D

@export var target:CharacterBody3D

@export var max_speed: float = 5.0  # Maximum speed (units per second)
@export var max_force: float = 10.0  # Maximum steering force (controls turning speed)
@export var max_acceleration: float = 20.0
@export var arrival_distance: float = 10.0  # Distance at which to slow down

func _physics_process(delta: float) -> void:
	if target:
		# Calculate the steering force for Seek
		var steering_force = seek(target.global_transform.origin)
		
		# Apply acceleration
		var acceleration = steering_force.clamp(Vector3(-max_acceleration, -max_acceleration, -max_acceleration), 
												Vector3(max_acceleration, max_acceleration, max_acceleration))
		
		velocity += acceleration * delta
		velocity = velocity.limit_length(max_speed)
		
		move_and_slide()
		
		# Draw gizmos for debugging
		draw_gizmos(steering_force, acceleration)


func seek(target_pos: Vector3) -> Vector3:
	# Calculate desired velocity (direction to target scaled by speed)
	var to_target = target_pos - global_transform.origin
	var distance = to_target.length()
	
	# Arrival behavior: scale speed based on distance
	var desired_speed = max_speed
	if distance < arrival_distance:
		desired_speed = max_speed * (distance / arrival_distance)  # Slow down near target
	
	var desired_velocity = to_target.normalized() * desired_speed
	
	# Calculate steering force (desired velocity - current velocity)
	var steering = desired_velocity - velocity
	
	# Clamp steering force
	return steering.clamp(Vector3(-max_force, -max_force, -max_force), 
							Vector3(max_force, max_force, max_force))

func draw_gizmos(steering_force: Vector3, acceleration: Vector3) -> void:
	var arrow_length = 2.0
	
	# Draw desired direction (blue)
	if target:
		var direction = (target.global_transform.origin - global_transform.origin).normalized()
		var direction_end = global_transform.origin + direction * arrow_length
		DebugDraw3D.draw_arrow(global_transform.origin, direction_end, Color.BLUE, 0.1)
	
	# Draw velocity (red)
	var velocity_end = global_transform.origin + velocity.normalized() * arrow_length
	DebugDraw3D.draw_arrow(global_transform.origin, velocity_end, Color.RED, 0.1)
	
	# Draw acceleration (yellow)
	var accel_end = global_transform.origin + acceleration.normalized() * arrow_length
	DebugDraw3D.draw_arrow(global_transform.origin, accel_end, Color.YELLOW, 0.1)
