extends Panel

@export var text : RichTextLabel
@export var animator : AnimationPlayer

func display_notification(content: String):
	text.text = "[center][b][i]" + content + "[/i][/b][/center]"
	animator.play("display_notification")
