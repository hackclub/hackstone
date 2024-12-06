extends CardController

func on_turn_start():
	super.on_turn_start()	
	
	var card = CardIndex.get_random_minion(func	(n): return card_name != n).instantiate()
	card_group_controller.add_child(card)
	card_group_controller.insert_card(card, card_group_controller.index_of_card(self), self.global_position)

	move_to_graveyard()
