extends Camera3D

# Référence au joueur que la caméra doit suivre
@onready var player : CharacterBody3D = $"../Player"

# Offset de la caméra par rapport au joueur
@export var offset : Vector3 = Vector3(0, 1, -2)  # Distance devant le joueur

var shake_amount: float = 0.1  # L'amplitude du tremblement
var shake_duration: float = 0.5  # La durée du tremblement en secondes
var shake_timer: float = 0.0
var original_position: Vector3 = Vector3.ZERO

# Facteur de lissage (valeur proche de 0 = plus lent, proche de 1 = plus rapide)
var smooth_speed : float = 0.2

func _ready() -> void:
	for child in owner.get_children():
		if child.has_signal("on_farmer_attacked"):
			child.on_farmer_attacked.connect(_on_farmer_ai_on_farmer_attacked)

# Appelée chaque frame
func _physics_process(delta: float) -> void:
	var target_position : Vector3
	if player:
		target_position = player.global_transform.origin + offset
	if shake_timer > 0:
		# Diminue le temps restant pour le tremblement
		shake_timer -= delta
		
		# Appliquer une petite variation aléatoire à la position de la caméra
		var shake_offset = Vector3(
			randf_range(-shake_amount, shake_amount), 
			randf_range(-shake_amount, shake_amount), 
			randf_range(-shake_amount, shake_amount)
		)
		global_transform.origin = target_position + shake_offset
	else:
		# Si le tremblement est terminé, réinitialiser la position d'origine
		global_transform.origin = global_transform.origin.lerp(target_position, smooth_speed)
		

func _on_farmer_ai_on_farmer_attacked(sender) -> void:
	if player.global_position.distance_to(sender.global_position) < 5:
		start_camera_shake(0.05, 0.3)

# Fonction pour démarrer le tremblement de caméra
func start_camera_shake(amount: float, duration: float):
	original_position = global_transform.origin
	shake_amount = amount
	shake_duration = duration
	shake_timer = shake_duration
