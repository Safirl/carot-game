class_name Player extends CharacterBody3D

var move_speed : float = 3.0
var accel = 5
var state : String = "idle"
var interactionState = "underground"
var last_direction : String = "walkdown"
@export var carrotsNumber = 0 
var direction : Vector3 = Vector3.ZERO
var is_shaking : bool = false
var durt_particles
@export var gravity = 9.8

var shake_amount: float = 0.1  # L'amplitude du tremblement
var shake_duration: float = 0.5  # La durée du tremblement en secondes
var shake_timer: float = 0.0

var impulse_direction: Vector3
var _is_dead : bool = false
var _is_shaking = false
var interaction_counter : int = 0
var jump_strength : float = 10.0 

#Holding input
var holding_time = 0.0
var is_holding_input = false
var hold_time_threshold = 0.2
var actived : bool = false
var spawn_position: Vector3

@onready var anim_player = $AnimatedSprite3D

signal on_pick_object()
signal _on_holding_state_changed(bisHolding)
signal objectToHeavy()

func _ready():
	for child in owner.get_children():
		if child && child.name.contains("CarotAI"):
			child.on_digged_up.connect(_add_carrot)
			child.on_died.connect(_remove_carrot)
	spawn_position = global_position
	durt_particles = $durt
	durt_particles.emitting = false # Désactiver l'émission au départ
	
func _process(delta: float) -> void:
	if is_holding_input:
		holding_time += delta
		

func _physics_process(delta):
	direction = Vector3.ZERO
	direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	direction.z = Input.get_action_strength("up") - Input.get_action_strength("down")
	direction = direction.normalized()
	
	var target_position : Vector3
	
	if is_shaking:
		apply_shake(delta)

	if direction != Vector3.ZERO:
		if direction.z > 0:
			state = "walkup"
		elif direction.z < 0:
			state = "walkdown"
		elif direction.x > 0:
			state = "walkright"
		elif direction.x < 0:
			state = "walkleft"
		last_direction = state
	else :
		state = "idle"
	
	if interactionState == "none":
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
				match last_direction:
					"walkdown":
						anim_player.play("DefaultDown")
					"walkup":
						anim_player.play("DefaultUp")
					"walkright":
						anim_player.play("DefaultRight")
					"walkleft":
						anim_player.play("DefaultLeft")
	elif interactionState == "dead":
		pass
	elif interactionState == "underground":
		direction.x = 0
		direction.y = 0
		direction.z = 0
		velocity = direction
		anim_player.play("underground")
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

	if !_is_dead :
		velocity = velocity.lerp(direction * move_speed, accel * delta)
	else : 
		velocity = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":	
		pass
		
func activeMecanism():
	actived = true
	return actived
func isActiveMecanism():
	return actived

func pick_object():
	if $ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").weight <= carrotsNumber:
		$ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").isPicked = true
		if $ShapeCast3D.OldClosestObject.has_method("digUp"):
			$ShapeCast3D.OldClosestObject.digUp()
		interactionState = "holding"
		state="holding"
		_on_holding_state_changed.emit(true)
		on_pick_object.emit()
	else:
		objectToHeavy.emit()
		
	
func throwObject():
	is_holding_input = false
	holding_time = 0.
	interactionState = "none"
	$ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").isPicked = false
	var throw_direction
	match last_direction:
		"walkdown":
			throw_direction = self.global_transform.basis.z.normalized() * -1
		"walkup":
			throw_direction = self.global_transform.basis.z.normalized() * 1
		"walkright":
			throw_direction = self.global_transform.basis.x.normalized() * 1
		"walkleft":
			throw_direction = self.global_transform.basis.x.normalized() * -1
	var throw_force = 4.0
	throw_direction.y = 1
	$ShapeCast3D.OldClosestObject.throw(throw_direction * throw_force)
	_on_holding_state_changed.emit(false)

func dropObject():
	is_holding_input = false
	holding_time = 0.
	$ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").isPicked = false
	interactionState = "none"
	_on_holding_state_changed.emit(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact()
	if event.is_action_released("Interact"):
		_onRelease()

func interact():
	if interactionState == "underground":
		if interaction_counter < 3: # Vérifier que l'on n'a pas atteint la limite
			control_underground()
			interaction_counter += 1 # Incrémenter le compteur à chaque appel
		else: 
			interactionState = "none"
			interaction_counter = 0
			littleJump()
			
	if $ShapeCast3D.OldClosestObject != null:
		match interactionState:
				"none":
					pick_object()
				"holding":
					if is_holding_input == false:
						is_holding_input = true
						holding_time = 0.0

func _onRelease():
	if $ShapeCast3D.OldClosestObject != null:
		match interactionState:
			"none":
				pass
			"holding":
				if is_holding_input == false:
					pass
				elif is_holding_input == true && holding_time <= hold_time_threshold:
					dropObject()
				else:
					throwObject()

func hit() -> void:
	if _is_dead:
		return
	_is_dead = true
	if interactionState == "holding":
		dropObject()
	interactionState = "dead"
	$FlashComponent.start_flash(.2)
	anim_player.play("dead")
	$AnimatedSprite3D.animation_finished.connect(_on_death_anim_finished)

func _on_death_anim_finished():
	global_transform.origin = spawn_position
	interactionState = "underground"
	_is_dead = false
	anim_player.play("underground")
	$AnimatedSprite3D.animation_finished.disconnect(_on_death_anim_finished)

func control_underground() -> void:
	is_shaking = true
	direction = Vector3.ZERO
	direction.x = 0
	direction.y = 0
	velocity = direction
	shake_timer = 0.5 
	durt_particles.emitting = true
	move_and_slide()


func apply_shake(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		
		# Générer un offset aléatoire autour de la position initiale
		var shake_offset = Vector3(
			randf_range(-shake_amount, shake_amount), # Tremblement sur l'axe X
			randf_range(-shake_amount, shake_amount), # Tremblement sur l'axe Y
			randf_range(-shake_amount, shake_amount)  # Tremblement sur l'axe Z
		)
		# Appliquer le tremblement par rapport à la position initiale
		global_transform.origin = spawn_position + shake_offset
	else:
		# Arrêter le tremblement et revenir à la position initiale
		is_shaking = false
		durt_particles.emitting = false
		global_transform.origin = spawn_position


func littleJump():
	if direction.y == 0:
		velocity.y =+ jump_strength
	

func get_state():
	return state

func _add_carrot():
	print(carrotsNumber)
	carrotsNumber += 1

func _remove_carrot():
	print(carrotsNumber)
	carrotsNumber -= 1
