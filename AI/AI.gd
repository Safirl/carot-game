extends CharacterBody3D

var speed = 2.
var accel = 10.
@onready var NavigationAgent = $NavigationAgent3D

# Cette fonction est appelée chaque frame pour déplacer l'IA
func _physics_process(delta):
	NavigationAgent.target_position = get_parent().get_node("target").global_transform.origin
	
	var direction = (NavigationAgent.get_next_path_position() - global_position).normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()
