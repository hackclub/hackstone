extends Camera3D

# Ray length
var ray_length = 1000
var current_hover = null

func find_hovered_card(mouse_pos:Vector2):
			
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = project_ray_origin(mouse_pos)
	params.to = params.from + project_ray_normal(mouse_pos) * ray_length
	params.exclude = []

	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	
	if result:
		return result.collider
	else:
		return null

# Called every frame. Detects a click and casts a ray from the camera.
func _input(event):
	var card = find_hovered_card(get_viewport().get_mouse_position())

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if card != null:
				print("Clicked card: ", card.name)
				card.on_clicked()
	else:
		if card != null:
			if current_hover == card:
				return # do nothing, we are just in state of hovering
			if current_hover != card:
				if current_hover != null:
					current_hover.on_hover_end()
				current_hover = card
				
				current_hover.on_hover_begin()
		else:
			if current_hover != card:
				if current_hover != null:
					current_hover.on_hover_end()
			current_hover = null
