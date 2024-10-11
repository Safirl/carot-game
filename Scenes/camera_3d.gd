extends Camera3D

# Référence au joueur que la caméra doit suivre
@onready var player : CharacterBody3D = $"../CharacterBody3D"

# Offset de la caméra par rapport au joueur
var offset : Vector3 = Vector3(0, 3, -20)  # Distance devant le joueur

# Facteur de lissage (valeur proche de 0 = plus lent, proche de 1 = plus rapide)
var smooth_speed : float = 0.05

# Appelée chaque frame
func _process(delta: float) -> void:
	if player:
		# Position cible de la caméra : position du joueur + offset
		var target_position : Vector3 = player.global_transform.origin + offset

		# Interpolation lissée entre la position actuelle de la caméra et la position cible
		global_transform.origin = global_transform.origin.lerp(target_position, smooth_speed)

		# Réinitialiser la rotation de la caméra
		global_transform.basis = Basis()  # Réinitialiser la matrice de base de la caméra

		# Assure que la caméra est orientée vers le haut
		global_transform.basis.y = Vector3.UP

		var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
		direction_to_player.x = 0  # Bloquer la rotation latérale
		look_at(global_transform.origin + direction_to_player, Vector3.UP)
