extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 5.5
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

# State values for locked velocity jumping
var jumping = false
var jump_vector = Vector2(-0.1, -0.1)
const NEUTRAL_JUMP_MOD = 0.7

# Values for jump-related input buffer
var buffered_move = false
var buffered_move_timer = 0.0
var buffered_vector
var buffered_jump = false
var buffered_jump_timer = 0.0

# Values for coyote jumping
var coyote_timer = 0.0
const COYOTE_LIMIT = 0.33

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
			elif ev.position.y > click_drag_origin.y:
				var rotation_mag = ev.position.y - click_drag_origin.y
				$CameraBar.rotate_x(deg_to_rad(-rotation_mag * VIEW_SENSITIVITY_MOD_Y))
				
			# If we're fully vertical (-60) or even with the ground (30), don't
			# go further than that. This code will need to be replaced with
			# a more cerebral handling of the camera regarding ceilings/floors
			if rad_to_deg($CameraBar.rotation.x) < -60.0:
				$CameraBar.rotation.x = deg_to_rad(-60.0)
			elif rad_to_deg($CameraBar.rotation.x) > 30:
				$CameraBar.rotation.x = deg_to_rad(30)
			click_drag_origin.y = ev.position.y
				

func _physics_process(delta):
	# Add change in time to input buffer variables
	if buffered_move:
		buffered_move_timer += delta
	if buffered_jump:
		buffered_jump_timer += delta
	coyote_timer += delta
		
	# reset input buffers
	if buffered_move_timer >= 0.35:
		buffered_move_timer = 0.0
		buffered_move = false
	if buffered_jump_timer >= 0.25:
		buffered_jump_timer = 0.0
		buffered_jump = false
	
	# Add the gravity and handle floor state resets
	if not is_on_floor():
		velocity.y -= gravity * delta
	if is_on_floor():
		coyote_timer = 0.0
		jumping = false
		#if we've got a jump buffered, this is the moment we want to trigger it
		#since we've just landed on the floor and we're before the normal
		#jump trigger
		if buffered_jump:
			jumping=true
			velocity.y = JUMP_VELOCITY
			buffered_jump = false
			
			#If we also have a movement command buffered, use that as our new
			#jump vector
			if buffered_move:
				jump_vector = buffered_vector
				buffered_move = false
			else:
				jump_vector = Vector2(0.0, 0.0)
			buffered_jump_timer = 0.0
		else:
			jump_vector = Vector2(0.0, 0.0)
		
		
	
	# Handle Jump (Default toggle jumping).
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor() or coyote_jumpable():
			#If we press jump while on the floor, it's a normal jump
			jumping = true
			velocity.y = JUMP_VELOCITY
			if buffered_move:
				jump_vector = buffered_vector
				buffered_move = false
			else:
				jump_vector = Vector2(velocity.x, velocity.z)
		else:
			#If we're not on the floor, we're trying to buffer a jump!
			buffered_jump = true
			buffered_jump_timer = 0.0
	
	
	
		
	# Default toggle key_turning
	key_turning = false
	
	# See above line 56 comment about lunacy
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
	
	# Add a dampening modifier to speed if the user is moving backwards
	var true_speed = SPEED
	if Input.is_action_pressed("ui_down"):
		true_speed = SPEED * .5
	
	# If the user jumping, then most movement inputs shouldn't be relevant
	# (Locked velocity jumping)
	# Add our current direction to the movement buffer to make changing
	# jump directions feel smoother
	if jumping:
		velocity.x = jump_vector.x
		velocity.z = jump_vector.y
		buffered_move = true
		buffered_vector = Vector2(direction.x * true_speed, direction.z * true_speed)
		buffered_move_timer = 0.0
	else:
		buffered_move = false
	
	# The only exception is if the user has started a jump with NO directional
	# velocity (a 'neutral jump')
	if is_on_floor() or in_neutral_jump():
		if direction:
			# A modifier for velocity that accounts for being in a neutral
			# jump. If not, the modifier is just a 1x
			var neutral_jump_mod = 1.0
			if in_neutral_jump():
				neutral_jump_mod = NEUTRAL_JUMP_MOD
			
			# LERP our current velocity upwards towards our maximum speed (minor delay)
			velocity.x = lerp(velocity.x, (direction.x * true_speed) * neutral_jump_mod, 0.5)
			velocity.z = lerp(velocity.z, (direction.z * true_speed) * neutral_jump_mod, 0.5)
			
			# If we just added a weakened velocity onto a neutral jump,
			# we have to update our jump vector so we no longer think we're
			# in a neutral jump
			if in_neutral_jump():
				jump_vector = Vector2(velocity.x, velocity.z)
			
		else:
			
			velocity.x = 0.0
			velocity.z = 0.0
	
	# Internal Godot function that does velocity/friction based movement
	# (I assume)
	move_and_slide()

#Shortscript for a jump with no movement vector
func in_neutral_jump():
	return jump_vector.x == 0 and jump_vector.y == 0 and jumping

#Shortscript for 'any movement key pressed'
func any_movement():
	return Input.is_action_pressed("ui_down") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right")

func coyote_jumpable():
	return coyote_timer <= COYOTE_LIMIT and not jumping
