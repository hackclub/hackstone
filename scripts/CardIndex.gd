extends Node3D

var card_library : Array[PackedScene] = [
	]
	
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	card_library.append(load("res://cards/party_parrot/card.tscn"))
	card_library.append(load("res://cards/dragon/card.tscn"))
	card_library.append(load("res://cards/opossum/card.tscn"))
	card_library.append(load("res://cards/orpheus_maximus/card.tscn"))
	card_library.append(load("res://cards/orpheus_orphling/card.tscn"))
	card_library.append(load("res://cards/orpheus_concerned/card.tscn"))


func get_random_card() -> PackedScene:
	var num = rng.randi_range(0, len(card_library)-1)
	var ret = card_library[num]
	return ret
	
