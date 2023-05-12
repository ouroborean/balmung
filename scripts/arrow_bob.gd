extends Node3D

const BOB_RANGE = .2
var cycle = 0
var direction = -0.02

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if abs(cycle) >= BOB_RANGE:
		direction *= -1
	cycle += direction
	position.y += direction
	
