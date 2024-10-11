class_name Player extends CharacterBody3D

var move_speed : float = 10.0
var state : String = "idle"
@onready var anim_player = $AnimatedSprite3D

func _ready():
	pass

func _process(_delta):
	pass
	
func _physics_process(delta):
	var direction : Vector3 = Vector3.ZERO
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.z = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = direction.normalized()

	# Déterminer l'état en fonction de la direction
	if direction != Vector3.ZERO:
		if direction.z > 0:
			state = "walkdown"
		elif direction.z < 0:
			state = "walkup"
		elif direction.x > 0:
			state = "walkright"
		elif direction.x < 0:
			state = "walkleft"
	else:
		state = "idle"
	
	# Jouer l'animation en fonction de l'état
	match state:
		"walkdown":
			anim_player.play("walkDown")
		"walkup":
			anim_player.play("walkDown")
		"walkright":
			anim_player.play("walkDown")
		"walkleft":
			anim_player.play("walkDown")
		"idle":
			anim_player.play("Default")

	
	velocity = direction * move_speed
	move_and_slide()
