extends ShapeCast3D



var target

func _process(delta: float) -> void:
	target_position = get_parent().get_node("NavigationAgent3D").get_next_path_position().normalized()
	#print(target_position)
	pass

func has_target():
	target = null
	if get_parent().current_state == get_parent().States.ATTACKING:
		return target
	if collision_result.size() < 1:
		return target
	target = _getClosestObject(collision_result)
	return target

func _getClosestObject(hitResult):
	var closestObject = null
	for hit in hitResult:
		var object = hit.collider
		if !object || (!object.name == "Player" && !object.is_in_group("Carrot")):
			continue
		if !closestObject:
			closestObject = object
			continue
		
		var object_position = object.global_position
		if global_transform.origin.distance_to(object_position) <  global_transform.origin.distance_to(closestObject.global_position):
			closestObject = object

	return closestObject
