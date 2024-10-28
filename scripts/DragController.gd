extends "res://scripts/CardGroupController.gd"

func get_desired_position(index: int) -> Vector3:
	return Vector3.ZERO

func get_desired_rotation(index: int):
	return Basis.IDENTITY.rotated(Vector3.UP, deg_to_rad(0.1 * float(index)))
