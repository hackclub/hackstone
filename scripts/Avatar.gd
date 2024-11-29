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
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(amount: int) -> void:
	
	# Handle damage label
	var anim_player: AnimationPlayer = $AnimationPlayer
	if amount > 0:
		await main_camera.initiate_camera_shake(amount, 10)
		damage_indicator_label.text = "[color=ff0000][center][b]" + str(-amount) + "[/b][/center]"
	elif amount < 0:
		damage_indicator_label.text = "[color=00ff00][center][b]+" + str(-amount) + "[/b][/center]"
	if amount != 0: anim_player.play("avatar_damaged")
	
	print(str(self.name) + " got damaged for " + str(amount))
	toughness -= amount
	refresh()
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
