extends Node

var display_name = "DefaultDisplay"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func assign_name(name):
	display_name = name
	$NameLabel.text = display_name

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
