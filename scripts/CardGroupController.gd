extends Node3D

@export var card_prefab : PackedScene
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

func get_cards_len() -> int:
	return len(managed_cards)
