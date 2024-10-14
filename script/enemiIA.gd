extends CharacterBody3D

@export var move_speed: float = 5.0  
@export var wander_radius: float = 20.0  
@onready var nav_agent = $NavigationAgent3D
enum States { IDLE, CHASING, ATTACKING }
var current_state = States.IDLE
var accel = 1.

@onready var target = owner.get_node("Player")

func _physics_process(delta: float) -> void:
	if !target:
		return
	nav_agent.target_position = target.global_transform.origin
	match current_state:
		States.IDLE:
			_idle_behavior()

func _idle_behavior():
	var direction: Vector3
	if !global_transform.origin.distance_to(nav_agent.target_position) > nav_agent.target_desired_distance:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		current_state = States.IDLE
	else:
		print(nav_agent.get_next_path_position())
		direction = (nav_agent.get_next_path_position() - global_position).normalized()
		velocity = velocity.lerp(direction * move_speed, accel * get_physics_process_delta_time())
		move_and_slide()
	

#func choose_random_destination() -> Vector3:
	#var random_direction = Vector3(
		#randf_range(-1.0, 1.0),
		#0, 
		#randf_range(-1.0, 1.0)
	#).normalized()  
	#random_direction = global_transform.origin + random_direction * wander_radius
	#return random_direction
