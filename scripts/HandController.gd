class_name HandController
extends "res://scripts/CardGroupController.gd"
	
@export var hidden_hand = false
var original_rotation : Basis
@export var is_hovering = false
@export var opponent_hand_controller : HandController

func _ready() -> void:
	super._ready()
	original_rotation = transform.basis
	
func _process(delta: float) -> void:	
	super._process(delta)	
	var rotation : float
	rotation = float(get_cards_len())
	#transform.basis = transform.basis.slerp(original_rotation.rotated(Vector3.FORWARD, deg_to_rad(rotation)), delta * 15.0)
	
func insert_card(card: Node3D, index: int, global_position: Vector3) -> void:
	if !hidden_hand:
		Audio.play(ResourceLoader.load("res://sounds/defaults.tres").sounds.get("enter_hand"))
	super.insert_card(card, index, global_position)	
	card.show_power_toughness(!hidden_hand)	

func get_desired_position(index: int) -> Vector3:	
	var num_cards = get_cards_len()
	var desired_width = clampf(pow(1.25, float(num_cards)) * 3, 0, 15)
	var width_per_card = float(desired_width) / float(num_cards)

	if num_cards == 1:
		return Vector3(0.75, 2, -0.01)

	var absolute_x_offset = width_per_card * float(index)
	var centered_x_offset = -(desired_width - width_per_card*2) / 2.0 + absolute_x_offset
	return Vector3(centered_x_offset, 2, -0.01 * float(index))

func get_desired_rotation(index: int) -> Basis:
	if is_hovering:
		return Basis.IDENTITY

	var num_cards = get_cards_len()
	var spread_degrees = deg_to_rad(float(num_cards) * 5)
	var index_ratio = float(index) / (float(num_cards)-1)
	var degs = spread_degrees * index_ratio
	var rot = Basis.IDENTITY
	if hidden_hand:
		rot = rot.rotated(Vector3.RIGHT, deg_to_rad(180))
		rot = rot.rotated(Vector3.FORWARD, deg_to_rad(180))
	if num_cards <= 1:
		return rot

	rot = rot.rotated(Vector3.FORWARD, degs - spread_degrees/2)
	rot = rot.rotated(Vector3.UP, deg_to_rad(-0.01 * float(index)))

	return rot
	
