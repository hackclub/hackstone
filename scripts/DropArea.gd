extends Area2D

var hovered = false
@onready var collision_shape = $CollisionShape2D

func _ready():
	if get_parent() is Control:
		get_parent().connect("resized", Callable(self, "_on_parent_resized"))
		_on_parent_resized()  # Set initial size

func _on_parent_resized():
	collision_shape.shape.extents = get_parent().size / 2

func _mouse_enter() -> void:
	hovered = true

func _mouse_exit() -> void:
	hovered = false
