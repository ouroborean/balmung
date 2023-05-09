extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 6.5
const VIEW_SENSITIVITY_MOD_X = 0.3
const VIEW_SENSITIVITY_MOD_Y = 0.2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var rotation_velocity_x = 0.0
var rotation_velocity_z = 0.0
var new_rotation_mod_x = 0.0
var new_rotation_mod_z = 0.0
var actively_moving_x = 0.0
var actively_moving_z = 0.0
var pressed = false
var drag_turning = false
var key_turning = false
var click_drag_origin

var ui_switch = {
	KEY_W: "ui_up",
	KEY_A: "ui_left",
	KEY_S: "ui_down",
	KEY_D: "ui_right"
}

func _ready():
	set_process_input(true)
	
func _input(ev):
	drag_turning = false
	if ev is InputEventMouseButton and ev.button_index == 2:
		pressed = ev.pressed
		click_drag_origin = Vector2(ev.position.x, ev.position.y)
		

	if ev is InputEventMouseMotion:
		if pressed and not key_turning:
			drag_turning = true
			if ev.position.x < click_drag_origin.x:
				var rotation_mag = click_drag_origin.x - ev.position.x
				rotate_y(deg_to_rad(rotation_mag * VIEW_SENSITIVITY_MOD_X))
			elif ev.position.x > click_drag_origin.x:
				var rotation_mag = ev.position.x - click_drag_origin.x
				rotate_y(deg_to_rad(-rotation_mag * VIEW_SENSITIVITY_MOD_X))
			click_drag_origin.x = ev.position.x
			
				
		if pressed:
			if ev.position.y < click_drag_origin.y:
				var rotation_mag = click_drag_origin.y - ev.position.y
				$CameraBar.rotate_x(deg_to_rad(rotation_mag * VIEW_SENSITIVITY_MOD_Y))
			elif ev.position.y > click_drag_origin.y:
				var rotation_mag = ev.position.y - click_drag_origin.y
				$CameraBar.rotate_x(deg_to_rad(-rotation_mag * VIEW_SENSITIVITY_MOD_Y))
			click_drag_origin.y = ev.position.y
				

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	key_turning = false
	if not drag_turning:
		if Input.is_action_pressed("turn_left"):
			rotate_y(deg_to_rad(4.0))
			key_turning = true
		if Input.is_action_pressed("turn_right"):
			rotate_y(deg_to_rad(-4.0))
			key_turning = true
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		print("X direction: " + str(direction.x))
		print("Z direction: " + str(direction.z))
		velocity.x = lerp(velocity.x, direction.x * SPEED, 0.1)
		velocity.z = lerp(velocity.z, direction.z * SPEED, 0.1)
		
	else:
		velocity.x = lerp(velocity.x, 0.0, 1)
		velocity.z = lerp(velocity.z, 0.0, 1)
		
	move_and_slide()
