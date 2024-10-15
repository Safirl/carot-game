extends CharacterBody3D

signal OnTouchedByTheFarmer
var spawn_position: Vector3

enum States { IDLE, CHASING, ATTACKING }
var current_state = States.IDLE
var state : String = "idle"
var last_direction : String = "idle"
var direction: Vector3

@export var wander_radius: float = 10.
@export var gravity = 9.8

var speed = 1.5
var accel = 1.
@onready var NavigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimatedSprite3D
@onready var ShapeCast = $ShapeCast3D

func _ready() -> void:
	spawn_position = global_position

# Cette fonction est appelée chaque frame pour déplacer l'IA
func _physics_process(delta):
	match current_state:
		States.IDLE:
			_idle()
		States.CHASING:
			_chasing()
		States.ATTACKING:
			_attacking()
			
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	# Déterminer l'état en fonction de la direction
	if direction != Vector3.ZERO:
		if abs(direction.x) < abs(direction.z):
			if direction.z > 0:
				state = "walkup"
			elif direction.z < 0:
				state = "walkdown"
		else:
			if direction.x > 0:
				state = "walkright"
			elif direction.x < 0:
				state = "walkleft"
		last_direction = state  # Met à jour la dernière direction
	else:
		state = "idle"
	
	match state:
		"walkdown":
			anim_player.play("walkingDown")
		"walkup":
			anim_player.play("walkingUp")
		"walkright":
			anim_player.play("walkingRight")
		"walkleft":
			anim_player.play("walkLeft")
		"idle":
			if current_state != States.ATTACKING:
				# Choisir l'animation idle en fonction de la dernière direction de mouvement
				match last_direction:
					"walkdown":
						anim_player.play("DefaultDown")
					"walkup":
						anim_player.play("DefaultUp")
					"walkright":
						anim_player.play("DefaultRight")
					"walkleft":
						anim_player.play("DefaultLeft")

func _chasing():
	var current_target = ShapeCast.has_target()
	if !current_target:
		current_state = States.IDLE
		return
	NavigationAgent.target_position = current_target.global_transform.origin
	if global_transform.origin.distance_to(NavigationAgent.target_position) < NavigationAgent.target_desired_distance:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		current_state = States.ATTACKING
	else:
		direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
		velocity = velocity.lerp(direction * speed, accel * get_physics_process_delta_time())
		move_and_slide()
 
func _idle():
	if ShapeCast.has_target():
		current_state = States.CHASING
		return
	if global_transform.origin.distance_to(NavigationAgent.target_position) < NavigationAgent.target_desired_distance || NavigationAgent.target_position == Vector3.ZERO:
		NavigationAgent.target_position = choose_random_destination()
	direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * get_physics_process_delta_time())
	move_and_slide()

func _attacking():	
	if anim_player.animation_finished.is_connected(_on_attack_finished):
		return
	anim_player.animation_finished.connect(_on_attack_finished)
	if last_direction == "walkdown" || last_direction == "walkright":
		anim_player.play("AttackRight")
	else:
		anim_player.play("AttackLeft")

func _on_attack_finished():
	anim_player.animation_finished.disconnect(_on_attack_finished)
	
	current_state = States.CHASING
	if global_transform.origin.distance_to(NavigationAgent.target_position) < NavigationAgent.target_desired_distance:
		OnTouchedByTheFarmer.emit()

func choose_random_destination() -> Vector3:
	var random_destination = Vector3(
		randf_range(-1.0, 1.0),
		0, 
		randf_range(-1.0, 1.0)
	).normalized()
	random_destination = NavigationServer3D.map_get_random_point(NavigationAgent.get_navigation_map(), 1, false)
	return random_destination
