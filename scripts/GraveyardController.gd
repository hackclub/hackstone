extends "res://scripts/CardGroupController.gd"

func get_desired_position(index: int) -> Vector3:
	return Vector3(0.001 * float(index), 0.001 * float(index), -0.03 * float(index))

func get_desired_rotation(index: int):
	return Basis.IDENTITY.rotated(Vector3.UP, 0)
