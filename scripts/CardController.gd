class_name CardController
extends Node3D

var animating = false
var tapped = false
var turned = false
var hovered = false
var moving = false
var anim_player = null

enum CardType {MINION, HACK}
enum CardState {TAP = 0, UNTAP = 1, TURN_DOWN = 2, TURN_UP = 3}
var test_state : CardState = 0
var queue = []
@export var card_name : String = ""
@export var power = 0
@export var toughness = 1
@export var label_title : RichTextLabel
@export var label_power : RichTextLabel
@export var label_toughness : RichTextLabel
@export var type : CardType
var original_basis : Basis
var debug = false
var card_group_controller = null
var current_toughness

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.name = card_name
	label_title.text = "[b]" + card_name + "[/b]"
	original_basis = self.transform.basis
	anim_player = $AnimationPlayer
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	var box = $CollisionShape3D
	# VERY IMPORTANT - shapes do not seem to be
	box.shape = (box.shape as BoxShape3D).duplicate()
	label_power.text = str(power)
	label_toughness.text = str(toughness)
	current_toughness = toughness
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_process_queue()
	if debug:
		print("transform: " + str(self.global_position))
	
func _process_queue():
	if animating == true:
		return
	
	var operation = dequeue()
	if operation != null:
		animating = true
		anim_player.play(operation)
		await anim_player.animation_finished
		animating = false
	

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
	if card_group_controller != null:
		card_group_controller.card_clicked(self)
	#do_next_test()

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
	if queue.is_empty():
		animating = false
	else:
		_process_queue()

func damage(amount):
	print(str(self.name) + " got damaged for " + str(amount))
	current_toughness -= amount
	label_toughness.text = str(current_toughness)
	
func is_dead():
	return current_toughness <= 0
	
func heal():
	current_toughness = toughness
	label_toughness.text = str(toughness)


func is_controlled_by_me():
	if card_group_controller == null:
		print("weird")
		return false
	return card_group_controller.is_controlled_by_me()		
