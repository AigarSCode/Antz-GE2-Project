extends RigidBody3D

@onready var target = $"../Marker3D"

var max_speed = 10


func _physics_process(delta: float) -> void:
	if target:
		var direction = (target.global_transform.origin - global_transform.origin).normalized()
		
		linear_velocity = direction * max_speed
	
