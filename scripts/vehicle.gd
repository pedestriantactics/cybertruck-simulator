extends VehicleBody3D

# extends VehicleBody
var max_rpm = 600.0
var max_rpm_reverse = 200.0
var max_torque = 80000.0
var max_steering = 0.5
var steering_speed = 5.0

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

# for switching the direction
var forward = true

# todo: fix the double acceleration bug when reversing when still moving forward

func is_moving_forward() -> bool:
	# Get the forward vector of the vehicle
	var forward_vector = transform.basis.z.normalized()
	# Calculate the dot product between the forward vector and the linear velocity
	var dot_product = forward_vector.dot(linear_velocity.normalized())
	# Return true if the vehicle is moving forward, false otherwise
	return dot_product > 0

func _physics_process(delta):

	# toggle the bool if the reverse switchc is pressed
	if Input.is_action_just_pressed("toggle_reverse"):
		forward = !forward

	var collision_info = move_and_collide(linear_velocity * delta)

	# check if there's a collision and then get the strength by comparing the previous velocity to the current velocity
	if collision_info:
		# var impact = previous_velocity.length() - linear_velocity.length()
		# get the velocity of the other object by getting the parent, casting it to a rigidbody, and then getting the velocity
		var collider = collision_info.get_collider()
		var other_velocity = 0
		var impact = 0
		# if it's another object that can move
		if collider is RigidBody3D:
			other_velocity = collider.linear_velocity
			impact = (linear_velocity - other_velocity).length()
			if impact > .01:
				#impact is very strong, let's make it reasonable
				impact = pow(impact / 30, 2)
				emit_signal("object_collision_occurred", impact, collision_info)
			
			# move the other object up about half a meter and then recalculate the collision
			# collider.translate(Vector3(0, .5, 0))
			# collision_info = move_and_collide(linear_velocity * delta)
			# try speeding up the other object to get it out of the way
			var new_velocity = collider.linear_velocity.normalized() * .05
			# make the velocity go up a little
			new_velocity.y += .005
			collider.apply_central_impulse(new_velocity)
			return
			# collider.apply_torque_impulse(collider.constant_torque * 1)
		# if it's a wall
		# else:
		# 	# if it's not another object you're hitting a wall, compare your velocity to the previous velocity
		# 	impact = (previous_velocity - linear_velocity).length()
		# 	if impact > .01:
		# 		#impact is very strong, let's make it reasonable
		# 		impact = pow(impact / 10, 2)
		# 		emit_signal("static_collision_occurred", impact)


			
	# trying detect static collisions outside the collider
	var static_impact = (previous_velocity - linear_velocity).length()
	if static_impact > .05:
		#impact is very strong, let's make it reasonable
		static_impact = pow(static_impact / 10, 2)
		emit_signal("static_collision_occurred", static_impact)

	previous_velocity = linear_velocity

	steering = lerp(steering, Input.get_axis("turn_right", "turn_left") * max_steering, steering_speed * delta)
	var acceleration = Input.get_axis("move_backward", "move_forward")

	if acceleration > 0:
		acceleration = 1
	elif acceleration < 0:
		acceleration = -1

	# this is where the first start delay happens
	if (forward and acceleration > 0 and previous_acceleration <= 0 and (linear_velocity.length() < 2 or linear_velocity.length() < 5 and is_moving_forward())):
		if accelerationTimer == 0:
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.acceleration_sounds)
		# if the timer has ended throttle it
		if accelerationTimer > accelerationDelaySeconds:
			accelerationTimer = 0
			emit_signal("shake_occurred", 5)
			previous_acceleration = acceleration
		else:
			accelerationTimer += delta
			acceleration = 0
			return;

	# brake if the brakes are on
	if acceleration < 0 and linear_velocity.length() > 0:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = mass / 2
		engine_force = 0
		previous_acceleration = acceleration
		return

	# brake if moving forward but you're in reverse
	if !forward and is_moving_forward() and acceleration > 0 and linear_velocity.length() > 2:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = mass / 2
		engine_force = 0
		previous_acceleration = acceleration
		return

	# simulated regenerative braking if not pressing the accelerator
	if acceleration == 0 and linear_velocity.length() > 0:
		if (previous_acceleration != acceleration and linear_velocity.length() > 5):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.braking_sounds)
		brake = mass / 8
		engine_force = 0
		previous_acceleration = acceleration
		return

	# # get the rpm of all the wheels and create an average
	var rpm = abs(($BL.get_rpm() + $BR.get_rpm() + $FL.get_rpm() + $FR.get_rpm()) / 4)

	# forward movement
	if forward and acceleration > 0:
		if (previous_acceleration != acceleration):
			accelerate_audio_stream_player.play_random(accelerate_audio_stream_player.soft_acceleration_sounds)
		brake = 0
		engine_force = acceleration * max_torque * (1 - rpm / max_rpm)
		previous_acceleration = acceleration
		return

	# backward movement
	if !forward and acceleration > 0:
		brake = 0
		engine_force = -acceleration * max_torque * (1 - rpm / max_rpm_reverse)
		previous_acceleration = acceleration
		return
	
	previous_acceleration = acceleration
