class_name Wander extends State

var noise:FastNoiseLite = FastNoiseLite.new()
@export var theta = 0
@export var amplitude = 15.0
@export var distance = 8
@export var frequency = 0.2
@export var radius = 5

var wander_target: Vector3
var wander_update_timer: float = 0.0
var wander_update_interval: float = 2.0

func enter(ant: CharacterBody3D) -> void:
	super.enter(ant)
	
	# Initialize wander target
	update_wander_target()
	
	# Initialize Perlin noise
	noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.seed = randi()
	noise.frequency = frequency
	noise.fractal_octaves = 4
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5
	theta = randf() * 100.0  # Random starting point

func exit() -> void:
	pass

func process(delta: float) -> void:
	# Check for obstacles (avoidance_force, strength)
	var avoidanceForces: Array = get_avoidance_force()
	if avoidanceForces[1] > 0.1:  # Transition to Avoidance if obstacle detected
		ant.change_state(ant.get_node("States/Avoidance"))
		return
	
	# Update theta for noise
	theta += delta
	
	# Update wander target if close or timer expires
	var distance_to_target = ant.global_transform.origin.distance_to(wander_target)
	wander_update_timer -= delta
	if distance_to_target < ant.arrival_distance or wander_update_timer <= 0.0:
		update_wander_target()
		wander_update_timer = wander_update_interval
	
	# Seek the wander target
	var target_pos = wander(delta)
	var steering_force = seek(target_pos)
	apply_movement(steering_force, delta)
	


func wander(delta) -> Vector3:
	# Get circle center ahead of ant
	var forward = ant.global_transform.basis.z.normalized()  # Ant's forward direction
	var circle_center = ant.global_transform.origin + forward * distance
	
	# Get Perlin noise offsets
	var noise_x = noise.get_noise_1d(theta) * amplitude  # Left/right sway
	var noise_z = max(0.0, noise.get_noise_1d(theta + 1000.0) * amplitude * 0.5)  # Forward/back sway (less pronounced)
	
	# Calculate target on wander circle with noise
	var angle = noise_x * PI * 0.25
	var target_offset = Vector3(sin(angle), 0, cos(angle)) * radius
	target_offset += Vector3(noise_x, 0, noise_z)  # Add noise for extra sway
	
	# Rotate offset to align with ant's forward direction
	var projected = ant.global_transform.basis
	wander_target = circle_center + (projected * target_offset)
	
	on_draw_gizmos()
	return wander_target

# Update the persistent wander target
func update_wander_target() -> void:
	# Set a new target ahead with random offset
	var forward = ant.global_transform.basis.z.normalized()
	var random_angle = randf_range(-PI/4, PI/4)
	var offset = Vector3(sin(random_angle), 0, cos(random_angle)) * radius
	var circle_center = ant.global_transform.origin + forward * distance
	wander_target = circle_center + (ant.global_transform.basis * offset)

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
		query.collision_mask = 1
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
		avoidance_force = avoidance_dir * strength * 100.0
		
		if avoidance_force.length() > 0.01:
			DebugDraw3D.draw_arrow(ant.global_transform.origin, ant.global_transform.origin + avoidance_force.normalized() * 2.0, Color.PURPLE, 0.1)
	
	return [avoidance_force, strength]


func on_draw_gizmos():
	var cent = ant.global_transform * (Vector3.BACK * distance)
	DebugDraw3D.draw_sphere(cent, radius, Color.HOT_PINK)
	DebugDraw3D.draw_line(ant.global_transform.origin, cent, Color.HOT_PINK)
	DebugDraw3D.draw_line(cent, wander_target, Color.HOT_PINK)
	DebugDraw3D.draw_position(Transform3D(Basis(), wander_target), Color.HOT_PINK)
