extends Node3D

@export var animation_speed = 5.0
var managed_cards : Array[Node3D] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:	
	for i in range(0, len(managed_cards)):
		managed_cards[i].transform.origin = \
		managed_cards[i].transform.origin.lerp(get_desired_position(i), \
		delta * animation_speed)		

		var orig_basis : Basis = managed_cards[i].original_basis
		var rotation : Basis = get_desired_rotation(i)
		managed_cards[i].transform.basis = managed_cards[i].transform.basis.slerp(orig_basis * rotation, delta * animation_speed)
	
func get_cards() -> Array[Node3D]:
	return managed_cards
	
func take_card(index: int) -> Node3D:
	if index < 0 or index >= len(managed_cards):
		print("Invalid index in take_card - ignoring")
		return
	var taken_card = managed_cards[index]
	managed_cards.remove_at(index)
	remove_child(taken_card)
	return taken_card
	
func insert_card(card: Node3D, index: int) -> void:
	managed_cards.insert(index, card)
	add_child(card)
	
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
