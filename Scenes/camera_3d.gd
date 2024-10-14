extends Camera3D

# Référence au joueur que la caméra doit suivre
@onready var player : CharacterBody3D = $"../Player"

# Offset de la caméra par rapport au joueur
@export var offset : Vector3 = Vector3(0, 1, -2)  # Distance devant le joueur

# Facteur de lissage (valeur proche de 0 = plus lent, proche de 1 = plus rapide)
var smooth_speed : float = 0.2

# Appelée chaque frame
func _physics_process(delta: float) -> void:
	if player:
		var target_position : Vector3 = player.global_transform.origin + offset
		global_transform.origin = global_transform.origin.lerp(target_position, smooth_speed)
