extends MeshInstance3D

@onready var rays:Array = [$RayCast3D, $RayCast3D2, $RayCast3D3, $RayCast3D4, 
							$RayCast3D5, $RayCast3D6, $RayCast3D7]

func _ready() -> void:
	pass


# Ray food detection code here
func _process(delta: float) -> void:
	for ray in rays:
		if ray.is_colliding():
			var collider = ray.get_collider()
