extends Node




# Called when the node enters the scene tree for the first time.
func _ready():
	
	var texture = load("res://images/jack1.png")
	$TextureRect/TextureButton.texture_normal = texture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_texture_button_mouse_entered():
	pass


func _on_texture_button_pressed():
	print("Ping")
