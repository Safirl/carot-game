extends CharacterBody3D

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
@onready var target = owner.get_node("Player")

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
	anim_player.play("walkingRight")
		
	#match state:
		#"walkdown":
			#anim_player.play("portaitFace")
		#"walkup":
			#anim_player.play("walkUp")
		#"walkright":
			#anim_player.play("portaitRight")
		#"walkleft":
			#anim_player.play("walkLeft")
		#"idle":
			## Choisir l'animation idle en fonction de la dernière direction de mouvement
			#match last_direction:
				#"walkdown":
					#anim_player.play("DefaultDown")
				#"walkup":
					#anim_player.play("DefaultUp")
				#"walkright":
					#anim_player.play("DefaultRight")
				#"walkleft":
					#anim_player.play("DefaultLeft")
			
func _chasing():
	##Replace with nearest target
	if !target:
		return
	NavigationAgent.target_position = target.global_transform.origin
	##End of repalce
	if !global_transform.origin.distance_to(NavigationAgent.target_position) > NavigationAgent.target_desired_distance:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		current_state = States.IDLE
	else:
		direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
		velocity = velocity.lerp(direction * speed, accel * get_physics_process_delta_time())
		move_and_slide()
	
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
	
func _idle():
	if global_transform.origin.distance_to(NavigationAgent.target_position) < NavigationAgent.target_desired_distance || NavigationAgent.target_position == Vector3.ZERO:
		NavigationAgent.target_position = choose_random_destination()
	var direction: Vector3
	direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
	velocity = velocity.lerp(direction * speed, accel * get_physics_process_delta_time())
	move_and_slide()
	

func _attacking():
	pass

func choose_random_destination() -> Vector3:
	var random_destination = Vector3(
		randf_range(-1.0, 1.0),
		0, 
		randf_range(-1.0, 1.0)
	).normalized()  
	random_destination = global_transform.origin + random_destination * wander_radius
	return random_destination
