extends Node3D

signal on_done_pressed
enum GameState {
	MY_TURN = 0,
	OPPONENT_TURN = 1
}

@export var my_avatar : NodePath
@export var my_battlefield : NodePath
@export var my_hand : NodePath
@export var my_deck : NodePath
@export var my_graveyard : NodePath

@export var opponent_avatar : NodePath
@export var opponent_battlefield : NodePath
@export var opponent_hand : NodePath
@export var opponent_deck : NodePath
@export var opponent_graveyard : NodePath

@export var dragger : NodePath

@export var panel_done : NodePath
@export var button_done : NodePath

@export var panel_notification : NodePath
@export var richtext_notification_message : NodePath
@onready var timer_finished_cb = connect("on_done_pressed", Callable(self, "_on_done_pressed"))

var state : GameState = GameState.MY_TURN
var instance = null

func add_card(card_scene, battlefield):
	var node3d_card = card_scene.instantiate() as Node3D
	node3d_card.transform.origin = Vector3(0, -20, 50)
	get_node(battlefield).insert_card(node3d_card, 0, node3d_card.transform.origin)
	
func deal_cards():
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), my_hand)
	add_card(CardIndex.get_random_card(), my_hand)
	add_card(CardIndex.get_random_card(), my_hand)
	add_card(CardIndex.get_random_card(), my_hand)
	add_card(CardIndex.get_random_card(), my_hand)
	add_card(CardIndex.get_random_card(), opponent_hand)
	add_card(CardIndex.get_random_card(), opponent_hand)
	add_card(CardIndex.get_random_card(), opponent_hand)
	add_card(CardIndex.get_random_card(), opponent_hand)
	add_card(CardIndex.get_random_card(), opponent_hand)
	
	for i in 20:
		add_card(CardIndex.get_random_card(), my_deck)
		add_card(CardIndex.get_random_card(), opponent_deck)
		add_card(CardIndex.get_random_card(), my_graveyard)
		add_card(CardIndex.get_random_card(), opponent_graveyard)
		
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	deal_cards()
	refresh_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		var evt = event as InputEventKey
		if evt.keycode == KEY_SPACE:
			await run_tests()

func run_tests():
	var groups = [my_hand, my_graveyard, my_deck, my_battlefield]
	for i in 1000:
		var group = groups[randi() % groups.size()]
		if group != null:
			var card = get_node(group).random_card()
			if card != null and card.moving == false:
				print("clicking card")
				card_clicked(card)			
			await get_tree().create_timer(0.5).timeout
	print("loop done!")

func refresh_state():
	display_notification("Your turn" if state == GameState.MY_TURN else "Opponent's turn")
	configure_done_button("Done")

func _on_done_pressed():
	state = GameState.MY_TURN if state == GameState.OPPONENT_TURN else GameState.OPPONENT_TURN
	on_turn_start()
	refresh_state()

func on_turn_start():
	if state == GameState.OPPONENT_TURN:
		draw_card(get_node(opponent_hand), get_node(opponent_deck))
	else:
		draw_card(get_node(my_hand), get_node(my_deck))

func draw_card(hand, deck):	
	var card = deck.take_card(0)	
	if card == null:
		print("NOTE - player tried to draw a card, failed to do so")
	else:
		hand.insert_card(card, hand.get_cards_len(), card.global_position)
		
func configure_done_button(str):
	get_node(button_done).text = str
	
func display_notification(str):
	get_node(richtext_notification_message).text = "[center]%s[/center]" % str

func test_clicking(card: CardController):
	var parent = card.card_group_controller
	if parent == get_node(my_hand):
		parent.take(card)
		get_node(my_battlefield).insert_card(card, 0, card.global_position)
	elif parent == get_node(my_battlefield):
		parent.take(card)
		get_node(my_graveyard).insert_card(card, 0, card.global_position)
	elif parent == get_node(my_deck):
		draw_card(get_node(my_hand), get_node(my_deck))
	elif parent == get_node(my_graveyard):
		parent.take(card)
		if randf_range(0, 1.0) < 0.9:
			get_node(my_deck).insert_card(card, get_node(my_deck).get_cards_len(), card.global_position)
		else:
			get_node(my_battlefield).insert_card(card, 0, card.global_position)

func card_clicked(card: CardController):
	test_clicking(card)
