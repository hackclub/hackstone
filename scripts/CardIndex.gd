extends Node3D
const CardType = preload("res://scripts/CardController.gd").CardType

var card_library : Array[PackedScene] = []
var name_table : Dictionary = {}
var hacks : Array[PackedScene] = []
var minions : Array[PackedScene] = []

var rng = RandomNumberGenerator.new()

func add_card(scene:PackedScene):
	card_library.append(scene)
	var cardinstance = scene.instantiate()
	name_table[cardinstance.card_name] = scene
	match cardinstance.type:
		CardType.HACK:
			hacks.append(scene)
		CardType.MINION:
			minions.append(scene)
	cardinstance.queue_free()

func _ready() -> void:
	add_card(load("res://cards/party_parrot/card.tscn"))
	add_card(load("res://cards/dragon/card.tscn"))
	add_card(load("res://cards/opossum/card.tscn"))
	add_card(load("res://cards/orpheus_maximus/card.tscn"))
	add_card(load("res://cards/orpheus_orphling/card.tscn"))
	add_card(load("res://cards/orpheus_concerned/card.tscn"))


func get_random_card() -> PackedScene:
	var num = rng.randi_range(0, len(card_library)-1)
	var ret = card_library[num]
	return ret
		
func get_random_minion(name_filter:Callable = func(s: String): return true):
	var valid_minions = []
	for name in name_table.keys():
		if name_table[name] in minions and name_filter.call(name):
			valid_minions.append(name_table[name])
	
	return random_element(valid_minions)

func random_element(array: Array):
	var num = rng.randi_range(0, len(array)-1)
	var ret = array[num]
	return ret
