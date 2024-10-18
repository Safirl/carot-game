@tool
class_name base_button extends RigidBody3D

@export var weight_treshold: int
#You must have an animation_component with methods : play_interacted_animation and play_activated_animation to use this component.
#This component is used to trigger events and animations.

##in meters
@export var collisionShapeSize: Vector3 = Vector3(1,1,1):
	set(new_collision):
		collisionShapeSize = new_collision
		_refresh_collision()

@export var texture : Texture:
	set(new_texture):
		texture = new_texture
		_editor_update_material()

@export var texture_1: Texture
@export var texture_2: Texture

var isActivated = false
signal on_button_activated
@export var activation_threshold: int

var interaction_number = 0

func _on_body_entered(body: Node) -> void:
	if body.name == "boat":
		print("end")
		get_tree().change_scene_to_file("res://Scenes/end_scene.tscn")
	elif body.has_node("PickableObjectComponent") && body.get_node("PickableObjectComponent").weight >= weight_treshold:
		activate()

func activate():
	if isActivated:
		return
	interaction_number += 1
	if interaction_number >= activation_threshold:
		on_button_activated.emit()
		isActivated = true
		$CollisionShape3D.queue_free()

	# Dupliquer le matériau avant de le modifier
	var material = $MeshInstance3D.mesh.surface_get_material(0).duplicate()
	match interaction_number:
		1:
			if texture_1:
				material.albedo_texture = texture_1
			else:
				queue_free()
		2:
			if texture_2:
				material.albedo_texture = texture_2
			else:
				queue_free()
	$MeshInstance3D.mesh.surface_set_material(0, material)

func highlight(bhighlight):
	if bhighlight:
		$Sprite3D.modulate = Color(1, 0, 0, 1)
	else:
		$Sprite3D.modulate = Color(1, 1, 1, 1)

func setFreeze(bfreeze: bool):
	print("highlight")

func _refresh_collision():
	if Engine.is_editor_hint():
		print("hi")
		get_node("CollisionShape3D").shape.size = collisionShapeSize

func _ready():
	_editor_update_material()
	if Engine.is_editor_hint():
		return

	# Dupliquer la forme de collision pour éviter que les instances la partagent
	var shape = $CollisionShape3D.shape.duplicate()
	$CollisionShape3D.shape = shape

	var mesh = $MeshInstance3D.mesh
	$MeshInstance3D.mesh = mesh
	

# Fonction qui met à jour le matériau en utilisant la texture définie
func _editor_update_material():
	
	if not Engine.is_editor_hint():
		return
	
	var mesh = PlaneMesh.new()
	# Si une texture est assignée, on crée ou met à jour le matériau
	if texture:
		# Vérifie si le mesh a déjà un matériau sinon on en crée un nouveau
		var material = StandardMaterial3D.new()
		print("new Material")
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		material.albedo_texture = texture
		$MeshInstance3D.mesh = mesh
		mesh.surface_set_material(0, material)
	else:
		mesh.surface_set_material(0, null)

func _update_material():
	if not Engine.is_editor_hint():
		return
	
	var mesh = PlaneMesh.new()
	# Si une texture est assignée, on crée ou met à jour le matériau
	if texture:
		# Vérifie si le mesh a déjà un matériau sinon on en crée un nouveau
		var material = StandardMaterial3D.new()
		print("new Material")
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
		material.albedo_texture = texture
		$MeshInstance3D.mesh = mesh
		mesh.surface_set_material(0, material)
	else:
		mesh.surface_set_material(0, null)
