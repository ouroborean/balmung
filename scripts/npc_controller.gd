extends CharacterBody3D

signal target_clicked(entity)
var npc_data

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
	

func assign_npc_data(entity_id):
	#TODO: add a connection to the database for storing
	#	entity information
	npc_data = load("res://scripts/npc.gd").new("Goblin", 50)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_targeted():
	npc_data.set_targeted()
	process_targeting()

func detarget():
	npc_data.detarget()
	process_targeting()
	
func process_targeting():
	if npc_data.targeted:
		var scene = load("res://assets/arrow.tscn")
		var instance = scene.instantiate()
		add_child(instance)
	else:
		$Arrow.queue_free()

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		target_clicked.emit(self)
