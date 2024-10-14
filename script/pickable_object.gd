class_name PickableObject extends RigidBody3D

var original_rotation: Basis
var camera_forward: Vector3

func _ready() -> void:
	# Conservez la rotation originale à l'initialisation
	original_rotation = global_transform.basis

	# Obtenez la direction avant de la caméra
	var camera = $"../Camera3D"  # Chemin vers votre caméra
	if camera:
		camera_forward = camera.global_transform.basis.z.normalized()  # Vecteur avant de la caméra

func _physics_process(delta: float) -> void:
	# Conservez la direction vers l'avant de la caméra
	var up_vector = Vector3.UP  # Garder l'axe vertical (Y) aligné avec l'axe UP global
	var right_vector = Vector3.RIGHT  # L'axe droit par défaut

	# Utiliser le vecteur avant de la caméra pour orienter l'objet
	var forward_vector = camera_forward

	# Mettre à jour la base (les axes de rotation) de l'objet pour l'orienter vers la caméra
	global_transform.basis = Basis(right_vector, up_vector, forward_vector)

# Fonction pour geler ou dégeler l'objet
func setFreeze(bfreeze: bool):
	freeze = bfreeze

# Fonction pour mettre en évidence l'objet avec une couleur rouge lorsqu'il est sélectionné
func highlight(bhighlight):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)  # Couleur rouge si l'objet est en surbrillance
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)  # Couleur blanche par défaut

# Fonction pour lancer l'objet avec une force d'impulsion
func throw(impulse: Vector3):
	apply_central_impulse(impulse)
