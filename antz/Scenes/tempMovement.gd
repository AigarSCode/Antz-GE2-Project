extends CharacterBody3D


func _physics_process(delta: float) -> void:
	var input_dir = Vector3.ZERO
	
	if Input.is_action_pressed("ui_up"):
		input_dir -= transform.basis.z
	if Input.is_action_pressed("ui_down"):
		input_dir += transform.basis.z
	if Input.is_action_pressed("ui_left"):
		input_dir -= transform.basis.x
	if Input.is_action_pressed("ui_right"):
		input_dir += transform.basis.x
		
	input_dir.y = 0  # Prevent vertical movement
	input_dir = input_dir.normalized()
	
	velocity.x = input_dir.x * 7.5
	velocity.z = input_dir.z * 7.5
	
	# You can apply gravity if needed:
	# velocity.y -= gravity * delta
	
	move_and_slide()
