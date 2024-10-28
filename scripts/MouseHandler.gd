extends Camera3D

# Ray length
var ray_length = 1000
var current_hover = null
var is_dragging = false
var drag_start_position = Vector2.ZERO
var click_threshold = 10  # Distance threshold to differentiate between click and drag
var clicked_card = null
var group_dragged_from = null
@onready var game_logic = get_node("../GameLogic")

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
		print("stopping hover on " + current_hover.name)
		current_hover.on_hover_end()
	current_hover = card
	if current_hover != null:
		print("starting hover on " + current_hover.name)
		current_hover.on_hover_begin()

func handle_dragmotion():
	if clicked_card == null or clicked_card.card_group_controller == null:
		print("Weird")
	
	var mouse_pos = get_viewport().get_mouse_position()

	# Get the ray origin and direction in world space from the camera
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_direction = project_ray_normal(mouse_pos)

	# Define a plane at y=0 (e.g., ground plane), or define your plane
	var plane = Plane(Vector3(0, 0, 1), 3)  # Plane facing up at y=0

	# Calculate intersection of ray with the plane
	var intersect_pos = plane.intersects_ray(ray_origin, ray_direction)
	clicked_card.card_group_controller.position_override = intersect_pos

func handle_mousemotion(event):
	if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		# Check if the mouse has moved enough to consider it a drag
		if not is_dragging and drag_start_position.distance_to(event.position) > click_threshold:
			is_dragging = true				
			print("transitioned to dragging")
			handle_dragmotion()
		elif is_dragging:
			handle_dragmotion()
	else:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		

func start_click(event, card: CardController):
	print("Clickdown on " + card.name)
	clicked_card = card
	is_dragging = false
	drag_start_position = event.position
	group_dragged_from = card.card_group_controller
	var gp = card.global_position
	get_node(game_logic.dragger).insert_card(group_dragged_from.take(card), 0, gp)
	handle_dragmotion()

func on_dropped(event, card: CardController):
	print("Drop detected!")
	var gp = card.global_position
	card.card_group_controller.take(card)
	group_dragged_from.insert_card(card, 0, gp)
	clear_mouse_state()

func on_clicked(event, card: CardController):
	print("Click detected!")
	var gp = card.global_position
	card.card_group_controller.take(card)
	group_dragged_from.insert_card(card, 0, gp)
	clicked_card.on_clicked()
	clear_mouse_state()

func clear_mouse_state():
	is_dragging = false
	clicked_card = null
	drag_start_position = Vector2.ZERO
	group_dragged_from = null

func handle_mousebutton(event):
	hovering(null)
	var card = find_hovered_card(get_viewport().get_mouse_position())
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if card != null:
			start_click(event, card)
	elif not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_dragging:
			on_dropped(event, clicked_card)
		else:
			on_clicked(event, clicked_card)
	else:
		clicked_card = null
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		

# Called every frame. Detects a click and casts a ray from the camera.
func _input(event):
	if event is InputEventMouseButton:
		return handle_mousebutton(event)
	elif event is InputEventMouseMotion:	
		return handle_mousemotion(event)
	elif not is_dragging:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		
