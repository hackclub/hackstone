extends Camera3D

# Ray length
var ray_length = 1000
var current_hover = null
var is_dragging = false
var drag_start_position = Vector2.ZERO
var click_threshold = 10  # Distance threshold to differentiate between click and drag


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
	
func hovering(card):
	# no transition if its the same
	if card == current_hover:
		return
	if current_hover != null:
		current_hover.on_hover_end()
	current_hover = card
	if current_hover != null:
		current_hover.on_hover_begin()

func handle_mousemotion(event):
	if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# Check if the mouse has moved enough to consider it a drag
		if not is_dragging and drag_start_position.distance_to(event.position) > click_threshold:
			is_dragging = true	
			print("transitioned to dragging")
	else:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		


func handle_mousebutton(event):
	hovering(null)
	var card = find_hovered_card(get_viewport().get_mouse_position())
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if card != null:
			print("Clickdown on " + card.name)
			is_dragging = false
			drag_start_position = event.position
	elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_dragging:
			print("Drop detected!")
		else:
			print("Click detected!")
	else:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		

# Called every frame. Detects a click and casts a ray from the camera.
func _input(event):
	if event is InputEventMouseButton:
		return handle_mousebutton(event)
	elif event is InputEventMouseMotion:	
		return handle_mousemotion(event)
	elif not is_dragging:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		
