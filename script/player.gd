extends CharacterBody3D

var move_speed : float = 3.0
var accel = 5
var state : String = "idle"
var interactionState = "none"
var last_direction : String = "idle"
@export var carrotsNumber = 0 
var direction : Vector3 = Vector3.ZERO

#Holding input
var holding_time = 0.0
var is_holding_input = false
var hold_time_threshold = 0.2
var actived : bool = false

@onready var anim_player = $AnimatedSprite3D

func _ready():
	pass
	
func _process(delta: float) -> void:
	if is_holding_input:
		holding_time += delta
		

func _physics_process(delta):
	direction = Vector3.ZERO
	direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
	direction.z = Input.get_action_strength("up") - Input.get_action_strength("down")
	direction = direction.normalized()

	
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
	else:
		state = "idle"

	match state:
		"walkdown":
			anim_player.play("portaitFace")
		"walkup":
			anim_player.play("portaitUp")
		"walkright":
			anim_player.play("portaitRight")
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

	# Applique la vitesse de mouvement
	velocity = velocity.lerp(direction * move_speed, accel * delta)
	move_and_slide()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "CharacterBody3D":	
		pass
		
func activeMecanism():
	actived = true
	return actived
func isActiveMecanism():
	return actived

func pickObject():
	#print($ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent"))
	if $ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").weight <= carrotsNumber:
		$ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").isPicked = true
		interactionState = "holding"
	
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
	var throw_force = 5.0
	throw_direction.y = 1
	$ShapeCast3D.OldClosestObject.throw(throw_direction * throw_force)


func dropObject():
	is_holding_input = false
	holding_time = 0.
	$ShapeCast3D.OldClosestObject.get_node("PickableObjectComponent").isPicked = false
	interactionState = "none"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Interact"):
		interact()
	if event.is_action_released("Interact"):
		_onRelease()

func interact():
	if $ShapeCast3D.OldClosestObject != null:
		match interactionState:
				"none":
					pickObject()
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
