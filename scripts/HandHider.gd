extends Node

@export var animator : AnimationPlayer
@export var sound_resource : Resource

func _on_mouse_entered() -> void:
	animator.play("hand_display")
	Audio.play(sound_resource.sounds.get("hand_show"))

func _on_mouse_exited() -> void:
	print("on mouse exited")
	animator.play("hand_hide")
	Audio.play(sound_resource.sounds.get("hand_hide"))
