extends MeshInstance3D

@onready var rays:Array = [$RayCast3D, $RayCast3D2, $RayCast3D3, $RayCast3D4, 
							$RayCast3D5, $RayCast3D6, $RayCast3D7]
@onready var ant: CharacterBody3D = $".."

var previous_food_target: Vector3 = Vector3.ZERO

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
			handle_food_found(collider)


# Stop Repeated Calls to seek_food
func handle_food_found(collider) -> void:
	if collider:
		if collider.global_position == previous_food_target:
			pass
		else:
			ant.seek_food(collider)
			previous_food_target = collider.global_position
