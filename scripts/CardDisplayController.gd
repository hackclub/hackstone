extends "res://scripts/CardGroupController.gd"

@export var destination_cardgroup : Node = null
@export var timeout : float = 2.0

func insert_card(card: Node3D, index: int, global_position: Vector3) -> void:
	super.insert_card(card, index, global_position)	
	Thread.new().start(Callable(self, "_background_task").bind(card))

func get_desired_position(index: int) -> Vector3:
	return Vector3(0, 0, 0)

func get_desired_rotation(index: int) -> Basis:
	return Basis.IDENTITY

func _background_task(card):
	#print("Running background task")
	await get_tree().create_timer(timeout).timeout
	var c = self.take(card)
	destination_cardgroup.insert_card(c, 0, c.global_position)
	#print("Finished background task")
