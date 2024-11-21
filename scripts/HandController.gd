extends "res://scripts/CardGroupController.gd"
	
@export var hidden_hand = false
	
func insert_card(card: Node3D, index: int, global_position: Vector3) -> void:
	super.insert_card(card, index, global_position)	
	card.show_power_toughness(!hidden_hand)

func get_desired_position(index: int) -> Vector3:	
	var num_cards = get_cards_len()
	var desired_width = 4.0
	var width_per_card = float(desired_width) / float(num_cards)

	if num_cards == 1:
		return Vector3(0.75, 0, -0.01)

	var absolute_x_offset = width_per_card * float(index)
	var centered_x_offset = -(desired_width - width_per_card*2) / 2.0 + absolute_x_offset
	return Vector3(centered_x_offset, 0, -0.01 * float(index))

func get_desired_rotation(index: int) -> Basis:
	var num_cards = get_cards_len()
	var spread_degrees = deg_to_rad(70)
	var index_ratio = float(index) / (float(num_cards)-1)
	var degs = spread_degrees * index_ratio
	var rot = Basis.IDENTITY
	if hidden_hand:
		rot = rot.rotated(Vector3.RIGHT, deg_to_rad(180))
		rot = rot.rotated(Vector3.FORWARD, deg_to_rad(180))
	if num_cards <= 1:
		return rot

	rot = rot.rotated(Vector3.FORWARD, degs - spread_degrees/2)
	rot = rot.rotated(Vector3.UP, deg_to_rad(-0.1 * float(index)))

	return rot
	
