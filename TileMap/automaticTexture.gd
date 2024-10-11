@tool
extends MeshInstance3D

# Expose une variable texture à l'éditeur
@export var texture : Texture:
	set(new_texture):
		texture = new_texture
		_update_material()

# Une fois que le script est prêt, on initialise les changements
func _ready():
	_update_material()

# Fonction qui met à jour le matériau en utilisant la texture définie
func _update_material():

	if not Engine.is_editor_hint():
		return

	# Si une texture est assignée, on crée ou met à jour le matériau
	if texture:
		# Vérifie si le mesh a déjà un matériau sinon on en crée un nouveau
		var material = material_override
		if not material:
			material = StandardMaterial3D.new()
			print("new Material")
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
		material.albedo_texture = texture
		material_override = material
	else:
		material_override = null
