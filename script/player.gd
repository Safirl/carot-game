extends CharacterBody3D

var move_speed : float = 10.0
var state : String = "idle"
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
