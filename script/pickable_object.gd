@tool
class_name PickableObject extends RigidBody3D

var original_rotation: Basis
var camera_forward: Vector3

##in meters
@export var collisionShapeSize: Vector3 = Vector3(1,1,1):
	set(new_collision):
		collisionShapeSize = new_collision
		_refresh_collision()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	# Conservez la rotation originale à l'initialisation
	original_rotation = global_transform.basis

	# Obtenez la direction avant de la caméra
	var camera = $"../Camera3D"  # Chemin vers votre caméra
	if camera:
		camera_forward = camera.global_transform.basis.z.normalized()  # Vecteur avant de la caméra

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	# Conservez la direction vers l'avant de la caméra
	var up_vector = Vector3.UP  # Garder l'axe vertical (Y) aligné avec l'axe UP global
	var right_vector = Vector3.RIGHT  # L'axe droit par défaut

	# Utiliser le vecteur avant de la caméra pour orienter l'objet
	var forward_vector = camera_forward

	# Mettre à jour la base (les axes de rotation) de l'objet pour l'orienter vers la caméra
	global_transform.basis = Basis(right_vector, up_vector, forward_vector)

# Fonction pour geler ou dégeler l'objet
func setFreeze(bfreeze: bool):
	if Engine.is_editor_hint():
		return
	freeze = bfreeze

# Fonction pour mettre en évidence l'objet avec une couleur rouge lorsqu'il est sélectionné
func highlight(bhighlight):
	if Engine.is_editor_hint():
			return
	# Récupérer le chemin de la texture actuelle
	var current_texture_path = $Sprite3D.texture.get_path()
	
	if bhighlight:
		# Construire le chemin de la texture highlight (en ajoutant "-selec" avant l'extension du fichier)
		var highlight_texture_path = current_texture_path.replace(".png", "-selec.png")
		
		# Charger la nouvelle texture highlight
		if ResourceLoader.exists(highlight_texture_path):
			var highlight_texture = ResourceLoader.load(highlight_texture_path) as Texture
			$Sprite3D.texture = highlight_texture
		else:
			print("Erreur : Texture de surbrillance non trouvée pour ", highlight_texture_path)
	else:
		# Remettre la texture par défaut (en enlevant "-selec" du nom si c'était une texture highlight)
		if current_texture_path.ends_with("-selec.png"):
			var default_texture_path = current_texture_path.replace("-selec.png", ".png")
			
			# Charger la texture par défaut
			if ResourceLoader.exists(default_texture_path):
				var default_texture = ResourceLoader.load(default_texture_path) as Texture
				$Sprite3D.texture = default_texture
			else:
				print("Erreur : Texture par défaut non trouvée pour ", default_texture_path)
		else:
			$Sprite3D.modulate = Color(1, 1, 1, 1)

# Fonction pour lancer l'objet avec une force d'impulsion
func throw(impulse: Vector3):
	if Engine.is_editor_hint():
		return
	apply_central_impulse(impulse)

func _refresh_collision():
	if Engine.is_editor_hint():
		get_node("CollisionShape3D").shape.size = collisionShapeSize
