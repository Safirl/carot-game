extends CharacterBody3D

var move_speed : float = 10.0
var state : String = "idle"
@onready var interaction_radius = 100.0
var last_direction : String = "idle"  # Garde en mémoire la dernière direction du mouvement

@onready var anim_player = $AnimatedSprite3D

func _ready():
	pass

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
	pass
	
func throwObject():
	pass

func dropObject():
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Interact"):
		interact()

func interact():
	var space_state = get_world_3d().direct_space_state
		
	var sphere_shape = SphereShape3D.new()
	sphere_shape.radius = interaction_radius
	
	var query_params = PhysicsShapeQueryParameters3D.new()
	query_params.shape = sphere_shape
	query_params.transform = global_transform  
	query_params.collision_mask = 1  
	
	var result = space_state.intersect_shape(query_params, 32) 

	if result.size() < 1:
		return
		
	var closestObject = _getClosestObject(result)
	if !closestObject:
		return
	print(closestObject.name)
	
		

func _getClosestObject(hitResult) -> PickableObject:
	var closestObject : PickableObject = null
	for hit in hitResult:
		var object = hit.collider
		if !(object && object == PickableObject):
			continue
		if !closestObject:
			closestObject = object
			continue
		
		var object_position = object.global_position
		if global_transform.origin.distance_to(object_position) <  global_transform.origin.distance_to(closestObject.global_position):
			closestObject = object

	return closestObject

func _checkObjectReachability(object):
	if !object:
		return
	
