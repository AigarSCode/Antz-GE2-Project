extends CharacterBody3D

var target

@export var max_speed: float = 3.0  # Maximum speed (units per second)
@export var max_force: float = 10.0  # Maximum steering force (controls turning speed)
@export var max_acceleration: float = 12.5
@export var arrival_distance: float = 3.0  # Distance at which to slow down

var current_state: State
var food_pickedup:int = 0

func _ready() -> void:
	# Wander State by Default
	change_state($States/Wander)


func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process(delta)


func change_state(new_state) -> void:
	if current_state == new_state:
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(self)


# Food Detected code, seek to it
func seek_food(food) -> void:
	target = food
	change_state($States/GetFood)
