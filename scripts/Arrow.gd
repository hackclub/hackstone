extends Control

@export var start_point: Vector2
@export var end_point: Vector2
@export var line_color: Color = Color(1, 0, 0)  # Red color
@export var line_width: float = 10.0

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw():
	# Draw a line from start_point to end_point
	draw_line(start_point, end_point, line_color, line_width)
