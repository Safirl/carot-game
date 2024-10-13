extends CharacterBody3D

enum States { IDLE, CHASING, HOLDED, DEAD, UNDERGROUND, HOLDING }
var current_state = States.CHASING
var state : String = "idle"
var last_direction : String = "idle"

@export var gravity = 9.8

var speed = 1.
var accel = 1.
@onready var NavigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimatedSprite3D
@onready var target = owner.get_node("Player")

# Cette fonction est appelée chaque frame pour déplacer l'IA
func _physics_process(delta):
	match current_state:
		States.CHASING:
			_chasing()
		States.HOLDED:
			_holded()
		States.DEAD:
			_dead()
		States.UNDERGROUND:
			_underground()
			
	if not is_on_floor():
		velocity.y -= gravity * delta
			
func _chasing():
	if !target:
		return
	var direction: Vector3
	NavigationAgent.target_position = target.global_transform.origin
	if !global_transform.origin.distance_to(NavigationAgent.target_position) > NavigationAgent.target_desired_distance:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
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
	
	match state:
		"walkdown":
			anim_player.play("portaitFace")
		"walkup":
			anim_player.play("walkUp")
		"walkright":
			anim_player.play("portaitRight")
		"walkleft":
			anim_player.play("walkLeft")
		"idle":
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

func _holded():
	pass

func _dead():
	pass

func _underground():
	pass
	
	
#pickable object interface to implement
func setFreeze(bfreeze: bool):
	if bfreeze:
		gravity = 0.
	else:
		gravity = 9.8

func highlight(bhighlight: bool):
	if bhighlight:
		$AnimatedSprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$AnimatedSprite3D.modulate = Color(1, 1, 1, 1)
	pass
