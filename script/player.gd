extends CharacterBody3D

var move_speed : float = 10.0
var state : String = "idle"
var interactionState = "none"
var last_direction : String = "idle"
@export var carrotsNumber = 0 

#Holding input
var holding_time = 0.0
var is_holding_input = false
var hold_time_threshold = 0.5

@onready var anim_player = $AnimatedSprite3D

func _ready():
	pass
	
func _process(delta: float) -> void:
	if is_holding_input:
		holding_time += delta
		

func _physics_process(delta):
	var direction : Vector3 = Vector3.ZERO
	direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	direction.z = Input.get_action_strength("up") - Input.get_action_strength("down")
	direction = direction.normalized()

	# Déterminer l'état en fonction de la direction
	if direction != Vector3.ZERO:
		if direction.z > 0:
			state = "walkup"
		elif direction.z < 0:
			state = "walkdown"
		elif direction.x > 0:
			state = "walkright"
		elif direction.x < 0:
			state = "walkleft"
		last_direction = state  # Met à jour la dernière direction
	else:
		state = "idle"

	# Jouer l'animation en fonction de l'état
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

	# Applique la vitesse de mouvement
	velocity = direction * move_speed
	move_and_slide()

func pickObject():
	print("pick")
	if $ShapeCast3D.ClosestObject.weight <= carrotsNumber:
		$ShapeCast3D.ClosestObject.isPicked = true
		interactionState = "holding"
	
func throwObject():
	print("throw")
	is_holding_input = false
	holding_time = 0.
	interactionState = "none"
	$ShapeCast3D.ClosestObject.isPicked = false
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
	var throw_force = 5.0
	$ShapeCast3D.ClosestObject.apply_central_impulse(throw_direction * throw_force)


func dropObject():
	print("drop")
	is_holding_input = false
	holding_time = 0.
	$ShapeCast3D.ClosestObject.isPicked = false
	interactionState = "none"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact()
	if event.is_action_released("Interact"):
		_onRelease()

func interact():
	if $ShapeCast3D.ClosestObject != null:
		match interactionState:
				"none":
					pickObject()
				"holding":
					if is_holding_input == false:
						is_holding_input = true
						holding_time = 0.0

func _onRelease():
	if $ShapeCast3D.ClosestObject != null:
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
