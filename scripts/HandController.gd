extends "res://scripts/CardGroupController.gd"
	
@export var hidden_hand = false
	
func insert_card(card: Node3D, index: int) -> void:
	super.insert_card(card, index)	
	if hidden_hand:
		card.do_turn()

func get_desired_position(index: int) -> Vector3:
	var num_cards = get_cards_len()
	var desired_width = 5
	var width_per_card = float(desired_width) / float(num_cards)
	var absolute_x_offset = width_per_card * float(index)
	var centered_x_offset = -desired_width/2 + absolute_x_offset + width_per_card/2
	return Vector3(centered_x_offset, 0, 0.05 * float(index))

func get_desired_rotation(index: int) -> Basis:
	var num_cards = get_cards_len()
	var spread_degrees = deg_to_rad(90.0)
	var index_ratio = float(index) / (float(num_cards)-1)
	var degs = spread_degrees * index_ratio
	var rot = Basis.IDENTITY.rotated(Vector3.FORWARD, degs - spread_degrees/2)
	return rot
	
