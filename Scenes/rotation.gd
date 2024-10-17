extends GPUParticles3D

# Vitesse de rotation des particules
var rotation_speed : Vector3 = Vector3(0, 1, 0) # Rotation autour de l'axe Y

func _ready() -> void:
	# Activer l'orientation du système de particules pour pouvoir appliquer la rotation
	set_emitting(true)

func _process(delta: float) -> void:
	# Appliquer une rotation continue sur l'ensemble des particules
	rotate_y(rotation_speed.y * delta)
