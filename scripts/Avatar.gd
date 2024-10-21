extends Panel

@export var current_turn_indicator : NodePath

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node(current_turn_indicator).hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
