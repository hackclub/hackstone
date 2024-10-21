extends Node3D

signal on_done_pressed
enum GameState {
	MY_TURN = 0,
	OPPONENT_TURN = 1
}
enum TurnPhase {
	CRAFT = 0,
	ATTACK = 1
}

@export var my_avatar : NodePath
@export var opponent_avatar : NodePath
@export var my_battlefield : NodePath
@export var opponent_battlefield : NodePath
@export var panel_done : NodePath
@export var button_done : NodePath
@export var panel_notification : NodePath
@export var richtext_notification_message : NodePath
@onready var timer_finished_cb = connect("on_done_pressed", Callable(self, "_on_done_pressed"))

var state : GameState = GameState.MY_TURN
var phase : TurnPhase = TurnPhase.CRAFT

func add_card(card_scene, battlefield):
	var node3d_card = card_scene.instantiate() as Node3D
	#var node3d_card = card_prefab.instantiate() as Node3D
	node3d_card.transform.origin = Vector3(0, -20, 50)
	get_node(battlefield).insert_card(node3d_card, 0)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), my_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	add_card(CardIndex.get_random_card(), opponent_battlefield)
	refresh_state()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func refresh_state():
	if state == GameState.MY_TURN and phase == TurnPhase.CRAFT:
		display_notification("Your turn - casting phase")
		configure_done_button("End phase")
	elif state == GameState.MY_TURN and phase == TurnPhase.ATTACK:
		display_notification("Your turn - attack phase")
		configure_done_button("End turn")
	elif state == GameState.OPPONENT_TURN and phase == TurnPhase.CRAFT:
		display_notification("Opponent's turn - casting phase")
		configure_done_button("End phase")
	elif state == GameState.OPPONENT_TURN and phase == TurnPhase.ATTACK:
		display_notification("Opponent's turn - attack phase")
		configure_done_button("End turn")

func _on_done_pressed():
	end_phase()
	refresh_state()

func end_phase():
	if state == GameState.MY_TURN && phase == TurnPhase.CRAFT:
		phase = TurnPhase.ATTACK
	elif state == GameState.MY_TURN && phase == TurnPhase.ATTACK:
		state = GameState.OPPONENT_TURN
		phase = TurnPhase.CRAFT
	elif state == GameState.OPPONENT_TURN && phase == TurnPhase.CRAFT:
		phase = TurnPhase.ATTACK
	elif state == GameState.OPPONENT_TURN && phase == TurnPhase.ATTACK:
		state = GameState.MY_TURN
		phase = TurnPhase.CRAFT

func configure_done_button(str):
	get_node(button_done).text = str
	
func display_notification(str):
	get_node(richtext_notification_message).text = "[center]%s[/center]" % str
