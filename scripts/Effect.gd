class_name Effect

var toughness_mod : int
var power_mod : int
var name : String
var mechanic : Variant = null
var mechanic_description : Variant = null
var stackable : bool = false
var duration : int = INF

func _init(name:String):
	pass

func setToughnessMod(toughness_mod:int):
	self.toughness_mod = toughness_mod
	return self
	
func setPowerMod(power_mod:int):
	self.power_mod = power_mod
	return self
	
func setDuration(duration:int):
	self.duration = duration
	return self
	
func setStackable(stackable:bool):
	self.stackable = stackable
	return self

func setMechanic(mechanic : String, mechanic_description : String):
	self.mechanic = mechanic
	self.mechanic_description = mechanic_description
	return self
