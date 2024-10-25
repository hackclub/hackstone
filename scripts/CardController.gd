class_name CardController
extends Node3D

var animating = false
var tapped = false
var turned = false
var hovered = false
var anim_player = null

enum CardState {TAP = 0, UNTAP = 1, TURN_DOWN = 2, TURN_UP = 3}
var test_state : CardState = 0
var queue = []
@export var power = 0
@export var toughness = 1
@export var label_power : RichTextLabel
@export var label_toughness : RichTextLabel
var original_basis : Basis

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_basis = self.transform.basis
	anim_player = $AnimationPlayer
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	var box = $CollisionShape3D
	# VERY IMPORTANT - shapes do not seem to be
	box.shape = (box.shape as BoxShape3D).duplicate()
	label_power.text = str(power)
	label_toughness.text = str(toughness)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	process_queue()
	
func process_queue():
	if animating == true:
		return
		
	var operation = dequeue()
	if operation != null:
		animating = true
		anim_player.play(operation)
		await anim_player.animation_finished
	

func dequeue():
	if not queue.is_empty():
		return queue.pop_front()
	return null
		

func do_next_test():
	match test_state:
		CardState.TAP:
			do_tap()
			test_state += 1
		CardState.UNTAP:
			do_tap()	
			test_state += 1
		CardState.TURN_DOWN:
			do_turn()
			test_state += 1
		CardState.TURN_UP:
			do_turn()
			test_state += 1
		_:
			print("Nothing!")
	print("doing next test: " + str(test_state))
	if test_state >= 4:
		test_state = 0


func on_clicked() -> void:
	do_next_test()

func do_tap() -> void:	
	tapped = !tapped
	queue.append("tap" if tapped else "untap")
	
func do_turn():
	turned = !turned
	queue.append("turn_down" if turned else "turn_up")
	
func on_hover_begin():
	if turned:
		return
	#print("starting hover on: " + str(self))
	queue.append("hover_begin")
	
func on_hover_end():
	if turned:
		return
	#print("ending hover on: " + str(self))
	queue.append("hover_end")

func _on_animation_finished(anim_name):
	#print("Animation finished: " + anim_name + " on anim_player: " + str(anim_player))
	animating = false
