extends CharacterBody3D

signal target_clicked(entity)
var npc_data

const HEIGHT_MOD = 65
const DISTANCE_MOD = 0.8

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_overhead()
	


func assign_npc_data(entity_id):
	#TODO: add a connection to the database for storing
	#	entity information
	npc_data = load("res://scripts/npc.gd").new("Goblin", 50)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_viewport().get_camera_3d():
		var camera = get_viewport().get_camera_3d()
		if $OverheadPlate.visible:
			$OverheadPlate.visible = not camera.is_position_behind(global_transform.origin)
		var screen_pos_hp = camera.unproject_position(global_transform.origin)
		var player = get_node("../Player")
		var distance = abs(global_position - camera.global_position)
		
		var height = $Body.shape.height * HEIGHT_MOD
		var modifier = DISTANCE_MOD * consolidate_distance(distance)
		
		$OverheadPlate.position = Vector2(screen_pos_hp.x - 100, screen_pos_hp.y - (height - modifier))

func set_targeted():
	npc_data.set_targeted()
	process_targeting()
	toggle_overhead()

func generate_overhead():
	var scene = load("res://assets/overhead_plate.tscn")
	var node = scene.instantiate()
	node.visible = false
	
	node.get_node("NamePlate").assign_name(npc_data.name)
	
	add_child(node)

func toggle_overhead():
	$OverheadPlate.visible = not $OverheadPlate.visible

func consolidate_distance(distance):
	return distance.x + distance.y + distance.z	

func detarget():
	npc_data.detarget()
	process_targeting()
	toggle_overhead()
	
func process_targeting():
	pass

func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		target_clicked.emit(self)
