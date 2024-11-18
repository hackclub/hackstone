extends Node3D

@export var animation_speed = 5
@export var controlled_by_me = false
var managed_cards : Array[Node3D] = []
var current_drag_point = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	for i in range(0, len(managed_cards)):		
		var desired_pos = get_desired_position(i)
		managed_cards[i].transform.origin = \
		managed_cards[i].transform.origin.lerp(desired_pos, \
		delta * animation_speed)		
		
		if managed_cards[i].transform.origin.distance_squared_to(desired_pos) < 0.01:
			managed_cards[i].moving = false					
		
		var orig_basis : Basis = managed_cards[i].original_basis
		var rotation : Basis = get_desired_rotation(i)
		managed_cards[i].transform.basis = managed_cards[i].transform.basis.slerp(orig_basis * rotation, delta * animation_speed)
	
func get_cards() -> Array[Node3D]:
	return managed_cards

func take(card: CardController) -> Node3D:
	return take_card(managed_cards.find(card))	
	
func take_card(index: int) -> Node3D:
	if index < 0 or index >= len(managed_cards):
		print("Invalid index in take_card - ignoring")
		return
	var taken_card = managed_cards[index]
	managed_cards.remove_at(index)
	var global_position = taken_card.global_position
	remove_child(taken_card)	
	get_tree().root.add_child(taken_card)
	taken_card.global_position = global_position
	taken_card.card_group_controller = null
	return taken_card

func get_card_visibility():
	return true

func insert_card(card: Node3D, index: int, global_position: Vector3) -> void:
	card.set_visibility(get_card_visibility())
	card.moving = true
	if card.get_parent() != null:
		card.get_parent().remove_child(card)
	if index < 0 or index > len(managed_cards):
		print("PROBLEM! - " + str(index))
	managed_cards.insert(index, card)
	add_child(card)
	card.card_group_controller = self
	card.position = self.to_local(global_position)
	
func get_desired_position(index: int) -> Vector3:
	push_error("get_desired_position must be implemented")
	return Vector3.ZERO

func get_desired_rotation(index: int) -> Basis:
	push_error("get_desired_rotation must be implemented")
	return Basis.IDENTITY

func get_cards_len() -> int:
	return len(managed_cards)

func disappear_card(index: int):
	var card = take_card(index)	
	if card == null:
		return
		
	add_child(card)
	var target_pos = card.transform.origin + Vector3(20, 20, 10)

	var t = 0
	while t < 1.0:
		t = clamp(t + 2 * get_process_delta_time(), 0, 1)
		var new_position = lerp(card.transform.origin, target_pos, t)
		card.transform.origin = new_position
		await get_tree().process_frame
	remove_child(card)
	card.queue_free()
	
func _on_remove_card_button_pressed():
	await disappear_card(0)

func is_controlled_by_me():
	return controlled_by_me

func random_card() -> CardController:
	if managed_cards.size() == 0:
		return null
	return managed_cards[randi() % managed_cards.size()]

# By default, do nothing when cards are clicked...
func card_clicked(card: CardController):
	get_tree().current_scene.get_node("GameLogic").card_clicked(card)

func index_of_card(card: CardController):
	return managed_cards.find(card)
		

func set_drag_point(drag_point):
	current_drag_point = drag_point
