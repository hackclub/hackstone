extends Node3D

# Rotation in degrees per second
@export var rotation_speed: float = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Calculate the rotation amount (in radians)
	var rotation_amount = deg_to_rad(rotation_speed * delta)

	rotate_y(rotation_amount)
