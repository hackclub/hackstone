extends "res://scripts/CardGroupController.gd"

func get_desired_position(index: int) -> Vector3:
	var num_cards = get_cards_len()
	var desired_width = 20
	var width_per_card = float(desired_width) / float(num_cards)
	var absolute_x_offset = width_per_card * float(index)
	var centered_x_offset = -desired_width/2 + absolute_x_offset + width_per_card/2
	return Vector3(centered_x_offset, 0, 0)

func get_desired_rotation(index: int):
	return Basis.IDENTITY
