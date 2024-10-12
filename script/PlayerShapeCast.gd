extends ShapeCast3D

var ClosestObject: PickableObject

func _process(delta: float) -> void:
	if collision_result.size() < 1 || !collision_result.find(ClosestObject):
		if ClosestObject:
			ClosestObject.highlight(false)
		return
	var closestObject : PickableObject = _getClosestObject(collision_result)
	if closestObject == null:
		return
	if _checkObjectReachability(closestObject):
		if ClosestObject:
			ClosestObject.highlight(false)
		ClosestObject = closestObject
		ClosestObject.highlight(true)

func _getClosestObject(hitResult) -> PickableObject:
	var closestObject : PickableObject = null
	for hit in hitResult:
		var object = hit.collider
		if !object || object.get_script() != PickableObject:
			continue
		if !closestObject:
			closestObject = object
			continue
		
		var object_position = object.global_position
		if global_transform.origin.distance_to(object_position) <  global_transform.origin.distance_to(closestObject.global_position):
			closestObject = object

	return closestObject

func _checkObjectReachability(object) -> bool:
	if !object:
		return false
	var space_state = get_world_3d().direct_space_state
	var raycast = RayCast3D.new()
	add_child(raycast)
	raycast.add_exception(get_parent())
	raycast.global_transform.origin = global_transform.origin
	var direction = (object.global_transform.origin - global_transform.origin)
	raycast.target_position = direction * 100
	raycast.enabled = true
	raycast.force_raycast_update()
	
	if !raycast.is_colliding() or (raycast.is_colliding() and raycast.get_collider() == object):
		return true
	else:
		return false
