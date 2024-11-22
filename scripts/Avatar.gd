class_name Avatar
extends Node3D

@export var toughness_text : Node
var toughness : int = 20
var power : int = 0
var card_group_controller : Node = null
var hovered = false
@export var graveyard : Node = null 	# the graveyard associated w/ this card group controller
var type = Avatar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	refresh()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func damage(amount: int) -> void:
	print(str(self.name) + " got damaged for " + str(amount))
	toughness -= amount
	refresh()
#	
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
