extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _process(_delta):
	var camera = owner.get_node("Camera3D")
	var parent = get_parent()
	if !camera || !parent:
		return
		
	# Récupère la position de l'objet et de la caméra
	var obj_pos = parent.global_transform.origin
	var cam_pos = camera.global_transform.origin
	
	# Calcul de la direction de la caméra en se concentrant uniquement sur l'axe Y
	var direction_to_camera = (cam_pos - obj_pos).normalized()
	
	# On force la direction sur l'axe Y à 0 pour éviter toute inclinaison vers le haut ou le bas
	direction_to_camera.x = 0
	direction_to_camera.y = 0
	
	# Oriente l'objet vers la caméra uniquement sur l'axe Y
	parent.look_at(obj_pos + direction_to_camera, Vector3.UP)

	# Applique un léger offset pour incliner l'objet vers l'arrière (par exemple, de 10 degrés)
	var offset_angle = deg_to_rad(20)  # Convertit les degrés en radians
	parent.rotate_x(offset_angle)  # Incline l'objet autour de l'axe X vers l'arrière
