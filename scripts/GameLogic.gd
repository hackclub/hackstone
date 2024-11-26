extends Node3D

const CardType = preload("res://scripts/CardController.gd").CardType

signal on_done_pressed
enum GameState {
	MY_TURN = 0,
	OPPONENT_TURN = 1
}

@export var my_avatar : Node
@export var my_battlefield : Node
@export var my_hand : Node
@export var my_deck : Node
@export var my_graveyard : Node
@export var my_draw_display : Node

@export var opponent_avatar : Node
@export var opponent_battlefield : Node
@export var opponent_hand : Node
@export var opponent_deck : Node
@export var opponent_graveyard : Node
@export var dragger : Node

@export var panel_done : Node
@export var button_done : Node

@export var panel_notification : Node
@export var richtext_notification_message : Node
@onready var timer_finished_cb = connect("on_done_pressed", Callable(self, "_on_done_pressed"))
@export var sound_resource : Resource
@export var notifier : Node

var state : GameState = GameState.MY_TURN
var instance = null

func add_card(card_scene, card_group_controller):
	var node3d_card = card_scene.instantiate() as Node3D
	node3d_card.transform.origin = Vector3(0, -20, 50)
	card_group_controller.insert_card(node3d_card, 0, node3d_card.transform.origin)

	
func deal_cards():
	var time_between_cards = 0.25	
	for i in 7:
		add_card(CardIndex.get_random_card(), my_hand)
		add_card(CardIndex.get_random_card(), opponent_hand)
		await get_tree().create_timer(time_between_cards).timeout
	
	for i in 20:
		add_card(CardIndex.get_random_card(), my_deck)
		add_card(CardIndex.get_random_card(), opponent_deck)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	await deal_cards()
	await get_tree().create_timer(1).timeout
	await on_turn_start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func _input(event):
	#if event is InputEventKey and event.pressed:
		#var evt = event as InputEventKey
		#if evt.keycode == KEY_SPACE:
			#await run_tests()

func run_tests():
	var groups = [my_hand, my_graveyard, my_deck, my_battlefield]
	for i in 1000:
		var group = groups[randi() % groups.size()]
		if group != null:
			var card = group.random_card()
			if card != null and card.moving == false:
				print("clicking card")
				card_clicked(card)			
			await get_tree().create_timer(0.5).timeout
	print("loop done!")

func _on_done_pressed():	
	state = GameState.MY_TURN if state == GameState.OPPONENT_TURN else GameState.OPPONENT_TURN
	await on_turn_start()

func on_turn_start():
	Audio.play(sound_resource.sounds.get("turn_start"))
	await display_notification("Your turn" if state == GameState.MY_TURN else "Opponent's turn")
	configure_done_button("DONE")
	await get_tree().create_timer(2).timeout

	if state == GameState.OPPONENT_TURN:
		await reset_all_cards(opponent_battlefield)
		draw_card(opponent_hand, opponent_deck)
		await get_tree().create_timer(1.0).timeout
		Thread.new().start(Callable(self, "_perform_ai"))
	else:
		await reset_all_cards(my_battlefield)
		await draw_card(my_draw_display, my_deck)

func _perform_ai():
	var cur_mana = 10
	while(true):
		if my_avatar.toughness <= 0:
			return # Quick hack to fix bug on player's death
		await get_tree().create_timer(1.0).timeout
		var res = get_next_action(cur_mana)
		var next_action = res[1]
		cur_mana = res[0]
		if next_action == null:
			break
		next_action.call()
	await get_tree().create_timer(1.0).timeout
	_on_done_pressed()

# HACK: Returns an array of [int, Action] in order to keep track of mana for now
func get_next_action(mana: int) -> Array:
	if my_avatar == null || my_avatar.toughness <= 0:
		return [mana, null]
	
	var ai_hand_cards: Array[Node3D] = opponent_hand.get_cards()
	var ai_hand = opponent_hand
	var ai_battlefield_cards: Array[Node3D] = opponent_battlefield.get_cards()
	var ai_battlefield = opponent_battlefield
	var player_battlefield_cards: Array[Node3D] = my_battlefield.get_cards()
	var player_battlefield = my_battlefield
	
	var card = null
	var is_hack = false
	for i in ai_hand_cards:
		if i.casting_cost <= mana:
			card = i
			is_hack = i.type == CardType.HACK
			break


	if card != null:
		if not is_hack:
			return [mana - card.casting_cost, func(): ai_battlefield.insert_card(ai_hand.take(card), 0, card.transform.origin)]
		elif player_battlefield_cards.size() > 0: 
			return [mana - card.casting_cost, func(): card.play(player_battlefield_cards[randi() % player_battlefield_cards.size()])]
		else:
			return [mana - card.casting_cost, func(): card.play(my_avatar)]
	# Can't play any minions, must attack now
	for c in ai_battlefield_cards:
		if c.tapped == false:
			var rng = RandomNumberGenerator.new()
			var f = func(): 
				if rng.randf_range(0.0, 1.0)>0.5 && player_battlefield_cards.size() > 0:
					c.play(player_battlefield_cards[randi() % player_battlefield_cards.size()])
				else:
					c.play(my_avatar) # Attack player
	
			return [mana, f]
			
	
	
	return [mana, null]

func reset_all_cards(card_group_controller):
	for card in card_group_controller.get_cards():
		var should_pause = false
		if card.tapped:
			should_pause = true
			card.do_tap()
		if card.is_damaged():
			should_pause = true
			card.heal()
		if should_pause:
			await get_tree().create_timer(0.25).timeout

			
func draw_card(hand, deck):	
	Audio.play(sound_resource.sounds.get("draw"))
	var card = deck.take_card(0)	
	if card == null:
		print("NOTE - player tried to draw a card, failed to do so")
	else:
		hand.insert_card(card, hand.get_cards_len(), card.global_position)
		
func configure_done_button(str):
	button_done.text = str
	
func display_notification(str):
	notifier.display_notification(str)
	
func test_clicking(card: CardController):
	var parent = card.card_group_controller
	if parent == my_hand:
		parent.take(card)
		my_battlefield.insert_card(card, 0, card.global_position)
	elif parent == my_battlefield:
		parent.take(card)
		my_graveyard.insert_card(card, 0, card.global_position)
	elif parent == my_deck:
		draw_card(my_hand, my_deck)
	elif parent == my_graveyard:
		parent.take(card)
		if randf_range(0, 1.0) < 0.9:
			my_deck.insert_card(card, my_deck.get_cards_len(), card.global_position)
		else:
			my_battlefield.insert_card(card, 0, card.global_position)

func is_my_turn():
	return state == GameState.MY_TURN

func card_clicked(card: CardController):
	test_clicking(card)
