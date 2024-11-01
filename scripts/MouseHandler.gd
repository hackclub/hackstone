extends Camera3D

enum DragType { NONE, PLACEMENT, TARGET }
# Ray length
var ray_length = 1000
var current_hover = null
var is_dragging = false
var targeting = false
var drag_start_position = Vector2.ZERO
var click_threshold = 10  # Distance threshold to differentiate between click and drag
var clicked_card = null
var group_dragged_from = null
var old_drop_point = null
@onready var game_logic = get_node("../GameLogic")
@onready var battlefield_dropzone = get_node("../Dropzones/BattlefieldDropzone")
const CardType = preload("res://scripts/CardController.gd").CardType

func get_drop_point(mouse_position:Vector2):
	if battlefield_dropzone.hovered:
		var space_state = get_world_3d().get_direct_space_state()
		var params = PhysicsRayQueryParameters3D.new()
		var drop_point = project_ray_origin(mouse_position) + project_ray_normal(mouse_position) * 20
		return DropPoint.new(drop_point, get_node(game_logic.my_battlefield))
	return null

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
		
	if card != null and not card.is_controlled_by_me():
		return
		
	if current_hover != null:
		print("stopping hover on " + current_hover.name)
		current_hover.on_hover_end()
	current_hover = card
	if current_hover != null:
		print("starting hover on " + current_hover.name)
		current_hover.on_hover_begin()

func handle_placement_mousemotion():
	if clicked_card == null or clicked_card.card_group_controller == null:
		print("Weird")
		clear_mouse_state()
		return
		
	if not is_dragging and drag_start_position.distance_to(battlefield_dropzone.get_global_mouse_position()) > click_threshold:
		print("transitioned to dragging")
		is_dragging = true

	var mouse_pos = get_viewport().get_mouse_position()

	# Get the ray origin and direction in world space from the camera
	var ray_origin = project_ray_origin(mouse_pos)
	var ray_direction = project_ray_normal(mouse_pos)

	# Define a plane at y=0 (e.g., ground plane), or define your plane
	var plane = Plane(Vector3(0, 0, 1), 3)  # Plane facing up at y=0

	# Calculate intersection of ray with the plane
	var intersect_pos = plane.intersects_ray(ray_origin, ray_direction)
	clicked_card.card_group_controller.position_override = intersect_pos
	
	var drop_point = get_drop_point(battlefield_dropzone.get_global_mouse_position())
	if drop_point != null:
		if old_drop_point != null:
			old_drop_point.unhint()
			old_drop_point = null
		drop_point.hint()
		old_drop_point = drop_point
	else:
		if old_drop_point != null:
			old_drop_point.unhint()
			old_drop_point = null

func handle_targeting_mousemotion():
	if not is_dragging and drag_start_position.distance_to(battlefield_dropzone.get_global_mouse_position()) > click_threshold:
		print("transitioned to dragging")
		is_dragging = true
		
func determine_dragtype(card : CardController):
	var from_group = group_dragged_from
	if from_group == null and card != null:
		from_group = card.card_group_controller
				
	if from_group == get_node(game_logic.my_battlefield):
		print("battlefield target drag")
		return DragType.TARGET
	
	if from_group == get_node(game_logic.my_hand):
		print("was from hand")
		var type = card.type
		if clicked_card != null:
			type = clicked_card.type
		if type == CardType.HACK:
			return DragType.TARGET
		else:
			return DragType.PLACEMENT

	return DragType.NONE	
		
		
func handle_mousemotion(event):
	if event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		match determine_dragtype(clicked_card):
			DragType.TARGET:
				print("target mousemotion")
				handle_targeting_mousemotion()
			DragType.PLACEMENT:
				print("placement mousemotion")
				handle_placement_mousemotion()
			DragType.NONE:
				print("No drag type")
				pass
	else:
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		

func start_placement_click(event, card: CardController):
	print("Clickdown on " + card.name)
	if card == null or not card.is_controlled_by_me():
		print("Clicking not allowed on " + str(card.name))
		clear_mouse_state()
		return
	print("Starting click")
	clicked_card = card
	is_dragging = false
	drag_start_position = event.position
	group_dragged_from = card.card_group_controller
	var gp = card.global_position
	get_node(game_logic.dragger).insert_card(group_dragged_from.take(card), 0, gp)
	handle_placement_mousemotion()

func on_placement_dropped(event, card: CardController):
	print("Placement drop detected!")
	if card == null:
		print("weird")
		return

	if old_drop_point != null:
		old_drop_point.unhint()
		old_drop_point = null

	var gp = card.global_position
	var drop_point = get_drop_point(battlefield_dropzone.get_global_mouse_position())
	
	if drop_point != null:
		card.card_group_controller.take(card)
		var drop_index = drop_point.card_group_controller.current_drag_index
		drop_point.card_group_controller.insert_card(card, drop_index, gp)
	else:
		card.card_group_controller.take(card)
		group_dragged_from.insert_card(card, 0, gp)

	clear_mouse_state()

func on_placement_clicked(event, card: CardController):
	print("Click detected!")
	if card == null:
		print("weird")
		return
		
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
	if old_drop_point != null:
		old_drop_point.unhint()
		old_drop_point = null
	targeting = false

func handle_start_placement(event, card):
	if event.pressed:
		start_placement_click(event, card)
	else:
		if is_dragging:
			on_placement_dropped(event, clicked_card)
		else:
			on_placement_clicked(event, clicked_card)
			
func start_target_click(event, card):
	clicked_card = card
	group_dragged_from = card.card_group_controller
	targeting = true
	print("Should start targetting")

func on_target_dropped(event, card):
	print("Target completed")
	clear_mouse_state()
	
func on_target_clicked(event, card):
	print("Target card clicked")
	clear_mouse_state()
	
func handle_start_target(event, card):
	if event.pressed:
		start_target_click(event, card)
	else:
		if is_dragging:
			on_target_dropped(event, clicked_card)
		else:
			on_target_clicked(event, clicked_card)

func handle_left_button(event, hovered_card):		
	match determine_dragtype(hovered_card):
		DragType.PLACEMENT:
			return handle_start_placement(event, hovered_card)
		DragType.TARGET:
			return handle_start_target(event, hovered_card)

func handle_mousebutton(event):
	hovering(null)
	var card = find_hovered_card(get_viewport().get_mouse_position())	
	if card != null and event.button_index == MOUSE_BUTTON_LEFT:
		handle_left_button(event, card)
	else:
		clear_mouse_state()
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		

# Called every frame. Detects a click and casts a ray from the camera.
func _input(event):
	if event is InputEventMouseButton:
		return handle_mousebutton(event)
	elif event is InputEventMouseMotion:	
		return handle_mousemotion(event)
	elif (not is_dragging and not targeting):
		hovering(find_hovered_card(get_viewport().get_mouse_position()))		
