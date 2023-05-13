extends RefCounted

var name = "DefaultName"
var hp = -1
var targeted = false

func _init(new_name, new_hp=100):
	name = new_name
	hp = new_hp

func set_targeted():
	targeted=true

func detarget():
	targeted=false
