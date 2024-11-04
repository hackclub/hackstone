extends Area2D

var hovered = false

func _mouse_enter() -> void:
	hovered = true
	
func _mouse_exit() -> void:
	hovered = false
	
