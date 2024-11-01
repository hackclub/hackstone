# Define a new struct-like class
class_name DropPoint

# Define the struct properties
var point: Vector3
var card_group_controller: Node3D

# Optional: Create an initializer if you want to set properties when creating an instance
func _init(p: Vector3, cgc:Node3D) -> void:
	point = p
	card_group_controller = cgc

func hint():
	card_group_controller.set_drag_point(point)

func unhint():
	card_group_controller.set_drag_point(null)
