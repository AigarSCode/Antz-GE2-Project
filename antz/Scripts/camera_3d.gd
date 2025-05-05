extends Camera3D

var ant_camera_marker
var ant

func _ready() -> void:
	ant = $"../Ant"
	ant_camera_marker = ant.get_node("CameraTarget")

func _physics_process(delta: float) -> void:
	if ant_camera_marker:
		global_position = global_position.lerp(ant_camera_marker.global_position, 5 * delta)
		
		look_at(ant.global_position)
