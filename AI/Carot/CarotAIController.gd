extends CharacterBody3D

enum States { IDLE, CHASING, HOLDED, DEAD, UNDERGROUND, THROWN }
var current_state = States.CHASING
var state : String = "idle"
var last_direction : String = "idle"
var spawn_position: Vector3

var impulse_direction: Vector3
var impulse: float = 3
@export var gravity = 9.8
var is_shaking : bool = false

var shake_amount: float = 0.1  # L'amplitude du tremblement
var shake_duration: float = 0.5  # La durée du tremblement en secondes
var shake_timer: float = 0.0
@export var default_speed: float = 1.
var speed
var accel = 1.
@onready var NavigationAgent = $NavigationAgent3D
@onready var anim_player = $AnimatedSprite3D
@onready var target = owner.get_node("Player")
var isMapLoadded: bool
var _is_bumped
var _is_holding
var player
var original_position : Vector3
var has_target : bool = false

func _ready() -> void:
	
	print('target', target)
	target._on_holding_state_changed.connect(_on_player_holding_state_changed)
	
	player = target
	speed = default_speed
	spawn_position = global_position
	state = "underground"
	original_position = global_transform.origin
	has_target = false

# Cette fonction est appelée chaque frame pour déplacer l'IA
func _physics_process(delta):
	print(state)
	if !target || !isMapLoadded:
		isMapLoadded = true
		return
	NavigationAgent.target_position = target.global_transform.origin
	match current_state:
		States.IDLE:
			_idle()
		States.CHASING:
			_chasing()
		States.HOLDED:
			_holded()
		States.DEAD:
			_dead()
		States.UNDERGROUND:
			_underground()
		States.THROWN:
			_thrown()
		 
			
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
			
func _chasing():
	var direction: Vector3
	if !has_target : 
		return
	if !global_transform.origin.distance_to(NavigationAgent.target_position) > NavigationAgent.target_desired_distance:
		direction = Vector3.ZERO
		velocity = Vector3.ZERO
		current_state = States.IDLE
	else:
		direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
		if _is_bumped && is_on_floor():
			direction.y += 4
			_is_bumped = false
			velocity = direction
		else:
			velocity = velocity.lerp(direction * speed, accel * get_physics_process_delta_time())
	
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
	if !_is_holding:
		match state:
			"walkdown":
				anim_player.play("walkDown")
			"walkup":
				anim_player.play("walkUp")
			"walkright":
				anim_player.play("walkRight")
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
						
	elif state == "dead":
		_dead()
		
		
	elif state == "underground":
		print('is underground')
		has_target = false
		anim_player.play("underground")
		_underground()
	else:
		
		match state:
			"walkdown":
				anim_player.play("portaitDown")
			"walkup":
				anim_player.play("portaitUp")
			"walkright":
				anim_player.play("portaitRight")
			"walkleft":
				anim_player.play("portaitLeft")
			"idle":
		
				match last_direction:
					"walkdown":
						anim_player.play("DefaultPortaitDown")
					"walkup":
						anim_player.play("DefaultPortaitUp")
					"walkright":
						anim_player.play("DefaultPortaitRight")
					"walkleft":
						anim_player.play("DefaultPortaitLeft")

func _holded():
	velocity = Vector3.ZERO

func _dead():
	print('dead')
	has_target = false
	anim_player.play("dead")
	$AnimatedSprite3D.animation_finished.connect(_on_death_anim_finished)

	
func _on_death_anim_finished():
	$AnimatedSprite3D.animation_finished.disconnect(_on_death_anim_finished)
	anim_player.play("underground")
	global_transform.origin = original_position
	
	



func _underground():
	
	if !has_target : 
		print('is underground')
		velocity = Vector3.ZERO
		anim_player.play('underground')
		
	
	
	
	
	pass

func _holding():
	pass
	
func _idle():
	if !global_transform.origin.distance_to(NavigationAgent.target_position) < NavigationAgent.target_desired_distance:
		current_state = States.CHASING
	if _is_bumped:
		impulse_direction = Vector3.ZERO
		impulse_direction.y += 2
		velocity = impulse_direction * 2
		_is_bumped = false
#pickable object interface to implement
func setFreeze(bfreeze: bool):
	if bfreeze:
		gravity = 0.
		current_state = States.HOLDED
	else:
		gravity = 9.8
		current_state = States.THROWN
	

func highlight(bhighlight: bool):
	if bhighlight:
		$AnimatedSprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$AnimatedSprite3D.modulate = Color(1, 1, 1, 1)
	
#called when object is throw
func throw(impulse = Vector3(0, 0, 0)):
	impulse_direction = impulse
	current_state = States.THROWN
	
func _thrown():
	velocity = velocity.lerp(impulse_direction * impulse, get_physics_process_delta_time())
	impulse_direction.y -= .2
	if is_on_floor():
		velocity = Vector3.ZERO
		current_state = States.IDLE
		impulse_direction = Vector3.ZERO

func hit() -> void:
	state= "dead"
	$FlashComponent.start_flash(.1)
	_dead()

func _on_farmer_ai_on_farmer_attacked(sender) -> void:
	if global_transform.origin.distance_to(sender.global_position) < 5:
		_is_bumped = true
	
func _on_player_holding_state_changed(bisHolding: Variant) -> void:
	if bisHolding == true && (current_state != States.UNDERGROUND || current_state != States.DEAD):
		_is_holding = true
		if owner.name != "Player":
			target = owner.get_node("Player").get_node("ShapeCast3D").OldClosestObject
		speed = player.move_speed
	else:
		_is_holding = false
		target = owner.get_node("Player")
		speed = default_speed




func digUp():
	has_target = true
	state = "idle"
	anim_player.play("DefaultDown")
	

func get_state():
	return  
