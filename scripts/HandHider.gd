extends Node

@export var animator : AnimationPlayer
@export var sound_resource : Resource

var can_trigger = true

func _ready():
	$DebounceTimer.connect("timeout", Callable(self, "_on_debounce_timeout"))

func on_user_action():
	if can_trigger:
		# Handle the action
		print("Action triggered!")
		# Disable further triggers and start the debounce timer
		can_trigger = false
		$DebounceTimer.start()

func _on_debounce_timeout():
	# Re-enable triggers after the debounce timer
	can_trigger = true

func _on_mouse_entered() -> void:
	print("on mouse entered")
	#if can_trigger:
		## Handle the action
		#print("Action triggered!")
		## Disable further triggers and start the debounce timer
		#can_trigger = false
		#$DebounceTimer.start()
	animator.play("hand_display")
	Audio.play(sound_resource.sounds.get("hand_show"))

func _on_mouse_exited() -> void:
	print("on mouse exited")
	#if can_trigger:
		## Handle the action
		#print("Action triggered!")
		## Disable further triggers and start the debounce timer
		#can_trigger = false
		#$DebounceTimer.start()
	animator.play("hand_hide")
	Audio.play(sound_resource.sounds.get("hand_hide"))
