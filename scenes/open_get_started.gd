extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var url = "https://github.com/hackclub/hackstone/blob/main/README.md"

func _on_Button_pressed():
	# Open the URL in the default web browser
	OS.shell_open(url)
