extends Node3D

var card_library : Array[PackedScene] = [
	load("res://cards/party_parrot/card.tscn"),
	load("res://cards/dragon/card.tscn"),
	load("res://cards/opossum/card.tscn"),
	load("res://cards/orpheus_maximus/card.tscn"),
	load("res://cards/orpheus_orphling/card.tscn"),
	load("res://cards/orpheus_concerned/card.tscn")
	]
	
var rng = RandomNumberGenerator.new()
	
func get_random_card() -> PackedScene:
	var num = rng.randi_range(0, len(card_library)-1)
	print("Random card num: " + str(num))
	var ret = card_library[num]
	return ret
