extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_ability_list(abilities):
	var buttons = get_children()
	for i in range(abilities.size()):
		buttons[i].bind_ability(abilities[i])
	for button in buttons:
		if not button.ability:
			button.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
