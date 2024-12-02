class_name Avatar
extends Node3D

@export var toughness_text : Node
@export var damage_indicator_label : RichTextLabel
var toughness : int = 20
var power : int = 0
var card_group_controller : Node = null
var hovered = false
@export var graveyard : Node = null 	# the graveyard associated w/ this card group controller
var type = Avatar
@export var main_camera : Camera3D = null
@export var stars : Array[Node] = []
@export var starting_mana = 0
@export var mana = 0
@export var max_mana = 0
var interpolated_mana : float = 0
@export var mana_animation_speed : float = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_mana = starting_mana
	mana = starting_mana
	interpolated_mana = max_mana

	refresh()
	for star in stars:
		star.modulate = Color.DIM_GRAY

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if interpolated_mana != mana:
		if abs(interpolated_mana - mana) < 0.01:
			interpolated_mana = mana
		else:
			interpolated_mana = lerpf(interpolated_mana, float(mana), mana_animation_speed * delta)
		refresh_mana()

func refresh_mana():
	for i in range(0, 9):
		if interpolated_mana <= i:
			stars[i].modulate = Color.DIM_GRAY
		else:
			stars[i].modulate = Color.GOLDENROD
			
func damage(amount: int) -> void:
	# Handle damage label
	var anim_player: AnimationPlayer = $AnimationPlayer
	if amount > 0:
		main_camera.initiate_camera_shake(amount, 10)
		damage_indicator_label.text = "[color=ff0000][center][b]" + str(-amount) + "[/b][/center]"
	elif amount < 0:
		damage_indicator_label.text = "[color=00ff00][center][b]+" + str(-amount) + "[/b][/center]"
	if amount != 0: anim_player.play("avatar_damaged")
	
	print(str(self.name) + " got damaged for " + str(amount))
	toughness -= amount
	refresh()	
	await get_tree().create_timer(0.5).timeout
	if toughness <= 0:
		get_tree().change_scene_to_packed(load("res://scenes/gameover.tscn"))


func refresh():
	toughness_text.text = "[center]%d[/center]" % (toughness)


func _on_mouse_entered() -> void:
	hovered = true
	print("mouse entered avatar!")


func _on_mouse_exited() -> void:
	hovered = false
	print("mouse exited avatar!")

func set_max_mana(amount) -> void:
	max_mana = amount
	
func get_max_mana():
	return max_mana
	
func regen_mana():
	mana = max_mana

func check_cost(amount):
	return mana >= amount
	
func spend(amount):
	if not check_cost(amount):
		return false
	mana -= amount
	return true
