extends "res://scripts/CardGroupController.gd"

func get_desired_position(index: int) -> Vector3:
	var num_cards = get_cards_len()
	var desired_width = 20
	var width_per_card = float(desired_width) / float(num_cards)
	var absolute_x_offset = width_per_card * float(index)
	var centered_x_offset = -desired_width/2 + absolute_x_offset + width_per_card/2
	return Vector3(centered_x_offset, 0, 0)


func _on_add_card_button_pressed() -> void:
	print("adding card")
	var node3d_card = CardIndex.get_random_card().instantiate() as Node3D
	#var node3d_card = card_prefab.instantiate() as Node3D
	node3d_card.transform.origin = Vector3(0, -20, 50)
	insert_card(node3d_card, 0)


func _on_remove_card_button_pressed():
	var card = take_card(get_cards_len()-1)	
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
