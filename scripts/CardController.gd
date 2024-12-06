class_name CardController
extends Node3D

var debug = false
var animating = false
var tapped = false
var turned = false
var hovered = false
var moving = false
var in_play = false
enum CardType {MINION, HACK}
enum CardState {TAP = 0, UNTAP = 1, TURN_DOWN = 2, TURN_UP = 3}
var test_state : CardState = 0
var queue = []
var original_basis : Basis
var card_group_controller = null
var current_toughness
var engine : Node
var effects : Array[Effect] = []

@export var card_name : String = "Unknown"
@export var subtype : String = "Unknown"
@export var power = 0
@export var toughness = 1
@export var flavortext : String = "This text should be replaced"
@export var description : String = "[color=d500d9][b]Replace me[/b][/color]: Does something generic.  Please replace this with your own text."
@export var casting_cost : int = 10
@export var type : CardType
@export var sound_resource : Resource = null

@onready var label_title : RichTextLabel = $TitleViewport/Panel/TitleBackground/TitleLabel
@onready var label_power : RichTextLabel = $PowerToughnessViewport/Panel/TitleBackground/PowerContainer/Power
@onready var label_toughness : RichTextLabel = $PowerToughnessViewport/Panel/TitleBackground/ToughnessContainer/Heart
@onready var label_casting_cost : RichTextLabel = $CostViewport/CostPanel/CastingCostLabel
@onready var label_flavortext : RichTextLabel = $DescriptionViewport/CardInfo/MarginContainer2/Control/Flavortext
@onready var label_subtype : RichTextLabel = $DescriptionViewport/CardInfo/MarginContainer/VBoxContainer/TitleContainerHBox/Subtype
@onready var label_description : RichTextLabel = $DescriptionViewport/CardInfo/MarginContainer/VBoxContainer/VBoxContainer/Description
@onready var label_type : RichTextLabel = $DescriptionViewport/CardInfo/MarginContainer/VBoxContainer/TitleContainerHBox/CardType
@onready var label_damage_indicator : RichTextLabel = $DamageIndicatorViewport/DamageIndicatorPanel/DamageIndicatorLabel
@onready var asleep_indicator : Node = $card/TiredLabelSprite
@onready var power_container : Node = $PowerToughnessViewport/Panel/TitleBackground/PowerContainer
@onready var toughness_container : Node = $PowerToughnessViewport/Panel/TitleBackground/ToughnessContainer
@onready var cost_container : Node = $CostViewport/CostPanel
@onready var anim_player = $AnimationPlayer

func initialize(engine : Node):
	self.engine = engine
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if sound_resource == null:
		sound_resource = load("res://sounds/defaults.tres")
	self.name = card_name
	asleep_indicator.visible = false
	original_basis = self.transform.basis
	anim_player.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
	var box = $CollisionShape3D
	# VERY IMPORTANT - shapes do not seem to be
	box.shape = (box.shape as BoxShape3D).duplicate()
	current_toughness = toughness
	refresh_power_toughness()
	
func refresh_power_toughness():
	match type:
		CardType.MINION:
			label_type.text = "[b][right]Minion[/right][/b]"
		CardType.HACK:
			label_type.text = "[b][right]Hack[/right][/b]"
			power_container.visible = false
			toughness_container.visible = false
	label_power.text = "[center][b]" + str(power) + "[/b][/center]"
	label_toughness.text = "[center][b]" + str(current_toughness) + "[/b][/center]"
	label_casting_cost.text = "[b][center]%d[/center][/b]" % (casting_cost)
	label_flavortext.text = "[i]" + flavortext + "[/i]"
	label_description.text = make_description()
	label_title.text = "[center][b]" + card_name + "[/b][/center]"
	label_subtype.text = "[b]" + subtype + "[/b]"

func modify_stats(power_delta, toughness_delta):
	toughness += toughness_delta
	power += power_delta
	refresh_power_toughness()
		
func make_description():
	return description
	
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
	asleep_indicator.visible = tapped
	
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
	Audio.play(sound_resource.sounds.get("hit"))
	print(str(self.name) + " got damaged for " + str(amount))
	current_toughness -= amount
	
	var anim_player: AnimationPlayer = $AnimationPlayer
	if amount > 0:
		label_damage_indicator.text = "[color=ff0000][center][b]" + str(-amount) + "[/b][/center]"
	elif amount < 0:
		label_damage_indicator.text = "[color=00ff00][center][b]+" + str(-amount) + "[/b][/center]"
	if amount != 0: 
		queue.append("damaged")
	refresh_power_toughness()
	await get_tree().create_timer(0.5).timeout

	
func is_dead():
	return current_toughness <= 0
	
func heal():
	current_toughness = toughness
	refresh_power_toughness()

func is_damaged():
	return toughness != current_toughness

func show_power_toughness(visibility):
	power_container.visible = visibility
	toughness_container.visible = visibility

func show_cost(visibility):
	cost_container.visible = visibility

func is_controlled_by_me():
	if card_group_controller == null:
		print("weird")
		return false
	return card_group_controller.is_controlled_by_me()		

func move_to_graveyard():
	var graveyard = card_group_controller.graveyard
	card_group_controller.take(self)
	graveyard.insert_card(self, 0, self.global_position)


func play(target):
	print("Playing card %s on %s" % [name, target.name])
	queue.append("attack")
	await get_tree().create_timer(0.3).timeout
	target.damage(power)
		
	if target is CardController and target.is_dead():
		target.move_to_graveyard()

	damage(target.power)
	if is_dead():
		move_to_graveyard()
	else:		
		do_tap()

func get_adjacent_neighbors():
	var neighbors = []
	var group = self.card_group_controller
	var my_index = group.index_of_card(self)
	
	var i = 0
	for card in group.get_cards():
		var dist = abs(my_index - i) 
		if dist != 0 and dist < 2:
			neighbors.append(card) 
		i = i + 1
	return neighbors
	
func get_all_neighbors():
	var neighbors = []	
	for card in owner.card_group_controller.get_cards():
		if card != owner:
			neighbors.append(card)

func display_toast(msg):
	self.engine.display_toast(msg)

func on_entered_play():
	in_play = true
	show_cost(false)
	if not tapped:
		do_tap()
	Audio.play(sound_resource.sounds.get("enter_play"))
	for card in get_adjacent_neighbors():
		card.toughness += 5

func on_exited_play():
	in_play = false

func on_entered_graveyard():
	pass
	
func on_played_on(target):
	pass
	
func on_drawn():
	pass
	
func on_card_draw(card):
	pass
	
func on_death(killer):
	pass
	
func on_attack(target):
	pass
	
func on_attacked(attacker):
	pass
	
func on_targeted(attacker):
	pass
	
func on_damaged(attacker, amount):
	pass
	
func on_healed(healer, amount):
	pass

func on_turn_start():
	if tapped:
		do_tap()
	if is_damaged():
		heal()

func on_turn_end():
	if tapped:
		do_tap()
	if is_damaged():
		heal()
	
func on_neighbors_changed():
	pass
	
func on_enemy_neighbors_changed():
	pass

func on_enemy_draw_card():
	pass

func on_enemy_turn_start():
	pass
	
func on_enemy_turn_end():
	pass
