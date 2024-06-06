extends VehicleBody3D

# for stats
var total_distance_traveled_meters = 0
var total_distance_traveled_miles = 0
var maximum_speed_achieved_meters_per_second = 0
var maximum_speed_achieved_miles_per_hour = 0
@onready var blackboard = $"/root/Blackboard"

var pedal_stomps = 0

# for the beginning
var parked = true

# extends VehicleBody
var max_rpm = 2000
# var max_rpm_reverse = 200.0
var max_torque = 50000
var max_steering = 0.3
var steering_speed = 5.0

var forward_force = 1000000
var reverse_force = -30000
var brake_force = 3000	
var regen_brake_force = 1000

# this allows the burst to be toggled off for development testing
var toggle_burst = true

var accelerationDelaySeconds = .3
var accelerationTimer = 0.0
var previous_acceleration = 0.0

# for collisions
signal object_collision_occurred(impact, collision_info)
signal static_collision_occurred(impact)
# for shakes when accelerating
signal shake_occurred(impact)

var previous_velocity = Vector3()

@onready var accelerate_audio_stream_player = $TruckAccelerateAudioStreamPlayer
@onready var area_3d = $Area3D

@onready var bl = $BL
@onready var br = $BR
@onready var fl = $FL
@onready var fr = $FR

# for switching the direction
var forward = true

func _ready():
	DevConsole.command.connect(handle_command)
	DevConsole.help_text["burst"] = "Toggles the burst feature on and off."
	DevConsole.help_text["rpm"] = "rpm <number> - Sets the max rpm, or no number to check the current value"
	DevConsole.help_text["steering"] = "steering <number> - Sets the max steering, or no number to check the current value"

	if blackboard:
		# clear the blackboard
		blackboard.kvps = {}
		blackboard.kvps["total_distance_traveled_meters"] = 0

func handle_command(text_command):
	var check_command = ""

	# if the command contains set rpm
	check_command = "rpm"
	if text_command.contains(check_command):
		# remove set rpm from the command and remove spaces
		var rpm = text_command.replace(check_command, "").strip_edges()
		# if the command is a number
		if rpm.is_valid_float():
			# set the max rpm
			max_rpm = float(rpm)
		DevConsole.debug_print("rpm set to: " + str(max_rpm))

	# if the command contains set steering
	check_command = "steering"
	if text_command.contains(check_command):
		# remove set steering from the command and remove spaces
		var steering = text_command.replace(check_command, "").strip_edges()
		# if the command is a number
		if steering.is_valid_float():
			# set the max steering
			max_steering = float(steering)
		DevConsole.debug_print("steering set to: " + str(max_steering))

	match text_command:
		"burst":
			toggle_burst = !toggle_burst
			DevConsole.debug_print("burst toggled: " + str(toggle_burst))
		"rpm":
			DevConsole.debug_print("rpm: " + str(max_rpm))
		"steering":
			DevConsole.debug_print("steering: " + str(max_steering))


func is_moving_forward() -> bool:
	# Get the forward vector of the vehicle
	var forward_vector = transform.basis.z.normalized()
	# Calculate the dot product between the forward vector and the linear velocity
	var dot_product = forward_vector.dot(linear_velocity.normalized())
	# Return true if the vehicle is moving forward, false otherwise
	return dot_product > 0

func _physics_process(delta):

	if parked:
		if Input.is_action_just_pressed("toggle_reverse") and InputProcessor.can_process_game_input:
			parked = false
			return
		else:
			return

	# toggle the bool if the reverse switchc is pressed
	if Input.is_action_just_pressed("toggle_reverse") && InputProcessor.can_process_game_input:
		forward = !forward

	# add to distance traveled only if the car is moving
	if linear_velocity.length() > 0.5:
		total_distance_traveled_meters += linear_velocity.length() * delta
		# convert to miles
		total_distance_traveled_miles = total_distance_traveled_meters * 0.000621371
		# add to the blackboard
		if blackboard:
			blackboard.kvps["total_distance_traveled_meters"] = total_distance_traveled_meters
			blackboard.kvps["total_distance_traveled_miles"] = total_distance_traveled_miles

	# get the current speed
	var current_speed = linear_velocity.length()
	# if the current speed is greater than the maximum speed
	if current_speed > maximum_speed_achieved_meters_per_second:
		# set the maximum speed to the current speed
		maximum_speed_achieved_meters_per_second = current_speed
		# convert to miles per hour
		maximum_speed_achieved_miles_per_hour = maximum_speed_achieved_meters_per_second * 2.23694
		# add to the blackboard
		if blackboard:
			blackboard.kvps["maximum_speed_achieved_meters_per_second"] = maximum_speed_achieved_meters_per_second
			blackboard.kvps["maximum_speed_achieved_miles_per_hour"] = maximum_speed_achieved_miles_per_hour

	# var collision_info = move_and_collide(linear_velocity * delta)

	# # check if there's a collision and then get the strength by comparing the previous velocity to the current velocity
	# if collision_info:
	# 	# get the velocity of the other object by getting the parent, casting it to a rigidbody, and then getting the velocity
	# 	var collider = collision_info.get_collider()
	# 	var other_velocity = 0
	# 	var impact = 0
	# 	# if it's another object that can move
	# 	if collider is RigidBody3D:
	# 		other_velocity = collider.linear_velocity
	# 		impact = (linear_velocity - other_velocity).length()
	# 		if impact > 20:
	# 			#impact is very strong, let's make it reasonable
	# 			impact = pow(impact / 40, 2)
	# 			emit_signal("object_collision_occurred", impact, collision_info)
	# 		var new_velocity = collider.linear_velocity.normalized() * .05
	# 		# make the velocity go up a little
	# 		new_velocity.y += .005
	# 		collider.apply_central_impulse(new_velocity)
	# 		return


			
	# TODO rewrite this as an actual collision detection
	# trying detect static collisions outside the collider
	# var static_impact = (previous_velocity - linear_velocity).length()
	# if static_impact > .05:
	# 	#impact is very strong, let's make it reasonable
	# 	static_impact = pow(static_impact / 10, 2)
	# 	emit_signal("static_collision_occurred", static_impact)

	previous_velocity = linear_velocity

	var acceleration = 0
	
	if (InputProcessor.can_process_game_input == true):
		steering = lerp(steering, Input.get_axis("turn_right", "turn_left") * max_steering, steering_speed * delta)
		acceleration = Input.get_axis("move_backward", "move_forward")
		# prevent glitchy things when pressing back
		if acceleration < 0:
			acceleration = 0

	if acceleration > 0:
		acceleration = 1
	elif acceleration < 0:
		acceleration = -1

	# burst
	# this is where the first start delay happens
	if (toggle_burst and forward and acceleration > 0 and previous_acceleration <= 0 and (linear_velocity.length() < 2 or linear_velocity.length() < 5 and is_moving_forward())):
		if accelerationTimer == 0:
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.acceleration_sounds)
		# if the timer has ended throttle it
		if accelerationTimer > accelerationDelaySeconds:
			accelerationTimer = 0
			# burst accelerate by adding impulse to the car in it's normal direction
			var impule_multiplier = 80000
			apply_impulse(transform.basis.z * impule_multiplier)
			emit_signal("shake_occurred", 5)
			previous_acceleration = acceleration
			pedal_stomps += 1
			blackboard.kvps["pedal_stomps"] = pedal_stomps
		else:
			accelerationTimer += delta
			acceleration = 0
			return;

	# brake if the brakes are on
	if acceleration < 0 and linear_velocity.length() > 0:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = brake_force
		bl.use_as_traction = true
		br.use_as_traction = true
		engine_force = 0
		previous_acceleration = acceleration
		return

	# brake if moving forward but you're in reverse
	if !forward and is_moving_forward() and acceleration > 0 and linear_velocity.length() > 2:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = brake_force
		bl.use_as_traction = true
		br.use_as_traction = true
		engine_force = 0
		previous_acceleration = acceleration
		return

	# simulated regenerative braking if not pressing the accelerator
	if acceleration == 0 and linear_velocity.length() > 0:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = regen_brake_force
		# set the back wheels to have traction
		bl.use_as_traction = true
		br.use_as_traction = true
		# fr.use_as_traction = false
		# fl.use_as_traction = false
		engine_force = 0
		previous_acceleration = acceleration
		return

	# # get the rpm of all the wheels and create an average
	var rpm = abs((bl.get_rpm() + br.get_rpm() + fl.get_rpm() + fr.get_rpm()) / 4)

	# forward movement
	if forward and acceleration > 0:
		if (previous_acceleration != acceleration):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.soft_acceleration_sounds)
		brake = 0
		# engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
		bl.use_as_traction = false
		br.use_as_traction = false
		if rpm < 1000:
			print("rpm: " + str(rpm))
			# set the back wheels to not have traction
			# fr.use_as_traction = true
			# fl.use_as_traction = true
			engine_force = forward_force
		else:
			# set the back wheels to have traction
			# bl.use_as_traction = true
			# br.use_as_traction = true
			# fr.use_as_traction = false
			# fl.use_as_traction = false
			engine_force = 0
		# engine_force = 50000
		previous_acceleration = acceleration
		return

	# backward movement
	if !forward and acceleration > 0:
		# set the back wheels to have traction
		# bl.use_as_traction = true
		# br.use_as_traction = true
		# fr.use_as_traction = true
		# fl.use_as_traction = true
		bl.use_as_traction = true
		br.use_as_traction = true
		brake = 0
		# engine_force = -acceleration * max_torque * (1 - rpm / max_rpm_reverse)
		if rpm < 400:
			engine_force = reverse_force
		else:
			engine_force = 0
		
		# engine_force = reverse_force
		previous_acceleration = acceleration
		return
	
	previous_acceleration = acceleration
