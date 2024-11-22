extends Node

@export var animator : AnimationPlayer

func _on_mouse_entered() -> void:
	animator.play("hand_display")

func _on_mouse_exited() -> void:
	animator.play("hand_hide")
