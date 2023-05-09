extends CharacterBody3D


const SPEED = 7.0
const JUMP_VELOCITY = 6.5
const VIEW_SENSITIVITY_MOD_X = 0.3
const VIEW_SENSITIVITY_MOD_Y = 0.2


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#Rotational velocity values for lerping camera turn (eventually)
var rotation_velocity_x = 0.0
var rotation_velocity_z = 0.0
var new_rotation_mod_x = 0.0
var new_rotation_mod_z = 0.0
var actively_moving_x = 0.0
var actively_moving_z = 0.0

# State values for clicking, dragging, and key turning
var pressed = false
var drag_turning = false
var key_turning = false
var click_drag_origin

# This stuff runs once this node is fully loaded
func _ready():
	# lets the script access input
	set_process_input(true)


# pumps input events every frame
func _input(ev):
	#toggle drag_turning off by default; it will be set true in just a moment if
	#we're still dragging, but will remain false if we aren't
	drag_turning = false
	
	# more like if right-click, amirite?
	if ev is InputEventMouseButton and ev.button_index == 2:
		# toggle that we're mouse button down for the rest of the input function
		pressed = ev.pressed
		# update the last known position of the mouse with the mouse button down
		# to judge the rate at which it's traveling per frame for controlling
		# camera rotation speed
		click_drag_origin = Vector2(ev.position.x, ev.position.y)
		
	# more like if...mouse motion
	if ev is InputEventMouseMotion:
		
		# As long as we learned that the mouse button was pressed earlier and
		# the user isn't HOLDING THE TURN KEYS DOWN WHILE THEY MOUSE TURN LIKE
		# A LUNATIC
		if pressed and not key_turning:
			# Toggle drag turning on
			drag_turning = true
			
			#If the mouse's x position is different than the last remembered
			#place we click dragged, then the difference is the distance we're
			#attempting to mouse-turn since the last frame
			if ev.position.x < click_drag_origin.x:
				var rotation_mag = click_drag_origin.x - ev.position.x
				rotate_y(deg_to_rad(rotation_mag * VIEW_SENSITIVITY_MOD_X))
			elif ev.position.x > click_drag_origin.x:
				var rotation_mag = ev.position.x - click_drag_origin.x
				rotate_y(deg_to_rad(-rotation_mag * VIEW_SENSITIVITY_MOD_X))
			
			click_drag_origin.x = ev.position.x
			
		if pressed:
			
			# Same as above, but for the vertical adjustment. Since we don't
			# want to rotate the character vertically, we rotate the attached
			# empty CameraBar node instead.
			
			if ev.position.y < click_drag_origin.y:
				var rotation_mag = click_drag_origin.y - ev.position.y
				$CameraBar.rotate_x(deg_to_rad(rotation_mag * VIEW_SENSITIVITY_MOD_Y))
				print(rad_to_deg($CameraBar.rotation.x))
			elif ev.position.y > click_drag_origin.y:
				var rotation_mag = ev.position.y - click_drag_origin.y
				$CameraBar.rotate_x(deg_to_rad(-rotation_mag * VIEW_SENSITIVITY_MOD_Y))
				print(rad_to_deg($CameraBar.rotation.x))
				
			# If we're fully vertical (-60) or even with the ground (30), don't
			# go further than that. This code will need to be replaced with
			# a more cerebral handling of the camera regarding ceilings/floors
			if rad_to_deg($CameraBar.rotation.x) < -60.0:
				$CameraBar.rotation.x = deg_to_rad(-60.0)
			elif rad_to_deg($CameraBar.rotation.x) > 30:
				$CameraBar.rotation.x = deg_to_rad(30)
			click_drag_origin.y = ev.position.y
				

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Default toggle key_turning
	key_turning = false
	
	# See above comment about lunacy
	if not drag_turning:
		# Key turning functions: default keyed to A and D
		if Input.is_action_pressed("turn_left"):
			rotate_y(deg_to_rad(4.0))
			key_turning = true
		if Input.is_action_pressed("turn_right"):
			rotate_y(deg_to_rad(-4.0))
			key_turning = true
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		
		# LERP our current velocity upwards towards our maximum speed (minor delay)
		velocity.x = lerp(velocity.x, direction.x * SPEED, 0.2)
		velocity.z = lerp(velocity.z, direction.z * SPEED, 0.2)
		
	else:
		
		#LERP our current velocity downwards towards zero (nearly no delay)
		velocity.x = lerp(velocity.x, 0.0, .4)
		velocity.z = lerp(velocity.z, 0.0, .4)
		
	move_and_slide()
