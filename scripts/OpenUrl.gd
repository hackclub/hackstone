extends Node

@export var url : String

func open():
	OS.shell_open(url)
