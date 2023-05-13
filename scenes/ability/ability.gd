extends RefCounted



var name = ""
var cost = 0
var cooldown
var cooldown_remaining
var texture

func _init(new_name, new_cost, new_cooldown, new_image_path):
	name = new_name
	cost = new_cost
	cooldown = new_cooldown
	cooldown_remaining = 0.0
	texture = load("res://assets/ui/skill_icons/" + new_image_path + ".png")
	

func start_cooldown():
	cooldown_remaining = cooldown

func execute(user):
	print("Using ", name)
