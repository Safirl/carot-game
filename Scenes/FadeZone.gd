@tool
extends Area3D

@export var walls_to_fade: Array[Node3D]
var fade_speed : float = 5.0  # Vitesse du changement de transparence
var is_fading_out : bool = false  # Indique si on est en train de faire disparaître le mur
var is_fading_in : bool = false   # Indique si on est en train de faire réapparaître le mur

##in meters
@export var collisionShapeSize: Vector3 = Vector3(1,1,1):
	set(new_collision):
		collisionShapeSize = new_collision
		_refresh_collision()

# Appelée chaque frame pour faire le fade
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if is_fading_out:
		fade_out(delta)
	elif is_fading_in:
		fade_in(delta)

# Fonction pour faire disparaître progressivement le Sprite3D
func fade_out(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for wall in walls_to_fade:     
		var modulate_color = wall.modulate
		modulate_color.a = max(modulate_color.a - fade_speed * delta, 0)  # Réduit l'alpha jusqu'à 0
		wall.modulate = modulate_color
		if modulate_color.a == 0:
			is_fading_out = false  # Arrête de fade quand c'est invisible

# Fonction pour faire réapparaître progressivement le Sprite3D
func fade_in(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for wall in walls_to_fade:     
		var modulate_color = wall.modulate
		modulate_color.a = min(modulate_color.a + fade_speed * delta, 1)  # Augmente l'alpha jusqu'à 1
		wall.modulate = modulate_color
		if modulate_color.a == 1:
			is_fading_in = false  # Arrête de fade quand c'est complètement visible

# Fonction appelée lorsqu'un corps entre dans l'Area3D
func _on_body_entered(body: Node3D) -> void:
	if Engine.is_editor_hint():
		return
	if body.name == "Player":
		
		is_fading_out = true  # Commence à faire disparaître le mur

# Fonction appelée lorsqu'un corps sort de l'Area3D
func _on_body_exited(body: Node3D) -> void:
	if Engine.is_editor_hint():
		return
	if body.name == "Player":
		is_fading_in = true  # Commence à faire réapparaître le mur

func _refresh_collision():
	if Engine.is_editor_hint():
		get_node("CollisionShape3D").shape.size = collisionShapeSize
