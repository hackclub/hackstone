extends Node3D

signal on_done_pressed
enum GameState {
	MY_TURN = 0,
	OPPONENT_TURN = 1
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
	display_notification("Your turn" if state == GameState.MY_TURN else "Opponent's turn")
	configure_done_button("Done")

func _on_done_pressed():
	state = GameState.MY_TURN if state == GameState.OPPONENT_TURN else GameState.OPPONENT_TURN
	refresh_state()

func configure_done_button(str):
	get_node(button_done).text = str
	
func display_notification(str):
	get_node(richtext_notification_message).text = "[center]%s[/center]" % str
