extends CharacterBody3D

enum States { IDLE, CHASING, HOLDED, DEAD, UNDERGROUND, THROWN }
var current_state = States.CHASING
var anim_state : String = "underground"
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
var is_selected = false

signal on_digged_up
signal on_died

func _ready() -> void:
	target._on_holding_state_changed.connect(_on_player_holding_state_changed)
	for child in owner.get_children():
		if child.has_signal("on_farmer_attacked"):
			child.on_farmer_attacked.connect(_on_farmer_ai_on_farmer_attacked)
	player = target
	speed = default_speed
	spawn_position = global_position
	current_state = States.UNDERGROUND

# Cette fonction est appelée chaque frame pour déplacer l'IA
func _physics_process(delta):
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
				anim_state = "walkup"
			elif direction.z < 0:
				anim_state = "walkdown"
		else:
			if direction.x > 0:
				anim_state = "walkright"
			elif direction.x < 0:
				anim_state = "walkleft"							
		last_direction = anim_state  # Met à jour la dernière direction
	else:
		anim_state = "idle"
		
	var selected
	if is_selected:
		selected = "selected"
	else:
		selected = ""
		
	if !_is_holding:
		match anim_state:
			"walkdown":
				anim_player.play(selected + "walkDown")
			"walkup":
				anim_player.play(selected + "walkUp")
			"walkright":
				anim_player.play(selected + "walkRight")
			"walkleft":
				anim_player.play(selected + "walkLeft")
			"idle":
				# Choisir l'animation idle en fonction de la dernière direction de mouvement
				match last_direction:
					"walkdown":
						anim_player.play(selected + "DefaultDown")
					"walkup":
						anim_player.play(selected + "DefaultUp")
					"walkright":
						anim_player.play(selected + "DefaultRight")
					"walkleft":
						anim_player.play(selected + "DefaultLeft")
	else:
		match anim_state:
			"walkdown":
				anim_player.play(selected + "portaitDown")
			"walkup":
				anim_player.play(selected + "portaitUp")
			"walkright":
				anim_player.play(selected + "portaitRight")
			"walkleft":
				anim_player.play(selected + "portaitLeft")
			"idle":
				match last_direction:
					"walkdown":
						anim_player.play(selected + "DefaultPortaitDown")
					"walkup":
						anim_player.play(selected + "DefaultPortaitUp")
					"walkright":
						anim_player.play(selected + "DefaultPortaitRight")
					"walkleft":
						anim_player.play(selected + "DefaultPortaitLeft")

func _holded():
	velocity = Vector3.ZERO

func _dead():
	anim_player.play("dead")
	$AnimatedSprite3D.animation_finished.connect(_on_death_anim_finished)
	
func _on_death_anim_finished():
	$AnimatedSprite3D.animation_finished.disconnect(_on_death_anim_finished)
	current_state = States.UNDERGROUND
	global_transform.origin = spawn_position
	

func _underground():
	anim_player.play("underground")
	if is_selected:
		anim_player.play("selectedunderground")
	var direction = Vector3.ZERO
	velocity = direction

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

##called by its pickable component when the player is nearby
func highlight(bhighlight: bool):
	if bhighlight:
		is_selected = true
	else:
		is_selected = false
	
#called when object is thrown
func throw(impulse = Vector3(0, 0, 0)):
	impulse_direction = impulse
	current_state = States.THROWN

##thrown physics
func _thrown():
	velocity = velocity.lerp(impulse_direction * impulse, get_physics_process_delta_time())
	impulse_direction.y -= .2
	if is_on_floor():
		velocity = Vector3.ZERO
		current_state = States.IDLE
		impulse_direction = Vector3.ZERO

func hit() -> void:
	## if we are dead we don't want to be hit
	if current_state == States.UNDERGROUND || current_state == States.DEAD:
		return
	on_died.emit()
	$FlashComponent.start_flash(.1)
	current_state = States.DEAD

##when a nearby farmer is attacking, it bumps up the carrot
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
	anim_player.play("DefaultDown")
	current_state = States.IDLE
	on_digged_up.emit()

func get_state():
	return  
