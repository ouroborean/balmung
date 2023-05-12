extends Node

@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	#TODO: add loading/instantiation of player object (since it won't
	#	normally start in the scene)
	instantiate_entity(420, Vector3(10, 1, 10))
	instantiate_entity(69, Vector3(15, 1, -15))
	

func instantiate_entity(entity_id, pos = Vector3(0, 0, 0)):
	var entity = load("res://assets/enemy.tscn").instantiate()
	
	#get the entity's personal data and assign it
	entity.assign_npc_data(entity_id)
	add_child(entity)
	
	#connect the entity's target assignment behavior to the
	#player
	entity.target_clicked.connect(player._on_enemy_target_clicked)
	
	#set the entity's position
	entity.position = pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
