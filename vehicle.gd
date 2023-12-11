extends VehicleBody3D

# extends VehicleBody
@export var max_rpm = 600.0
@export var max_rpm_reverse = 200.0
@export var max_torque = 30000.0
@export var max_steering = 0.4
@export var steering_speed = 5.0

var accelerationDelaySeconds = .3
var accelerationTimer = 0.0
var previousAcceleration = 0.0

# for collisions
signal collision_occurred(impact)

var previous_velocity = Vector3()

# for switching the direction
var forward = true

# todo: fix the double acceleration bug when reversing when still moving forward

func _physics_process(delta):

	var collision_info = move_and_collide(linear_velocity * delta)

	# check if there's a collision and then get the strength by comparing the previous velocity to the current velocity
	if collision_info:
		# var impact = previous_velocity.length() - linear_velocity.length()
		# get the velocity of the other object by getting the parent, casting it to a rigidbody, and then getting the velocity
		var collider = collision_info.get_collider()
		var other_velocity = 0
		var impact = 0
		if collider is RigidBody3D:
			other_velocity = collider.linear_velocity
			impact = (linear_velocity - other_velocity).length()
			#impact is very strong, let's make it reasonable
			impact = pow(impact / 18, 2)
		else:
			# if it's not another object you're hitting a wall, compare your velocity to the previous velocity
			impact = (previous_velocity - linear_velocity).length()
			#impact is very strong, let's make it reasonable
			impact = pow(impact / 8, 2)
			
		# Check if the collision is from the side and the impact is above a certain threshold
		# if abs(collision_info.get_normal().y) < 0.7 and impact > some_threshold:  # Adjust the threshold as needed
		if impact > .01:
			emit_signal("collision_occurred", impact)
			print("emitted signal " + str(impact))

	previous_velocity = linear_velocity

	# toggle the bool if the reverse switchc is pressed
	if Input.is_action_just_pressed("toggle_reverse"):
		forward = !forward

	steering = lerp(steering, Input.get_axis("turn_right", "turn_left") * max_steering, steering_speed * delta)
	var acceleration = Input.get_axis("move_backward", "move_forward")

	if acceleration > 0:
		acceleration = 1
	else:
		acceleration = -1

	# this is where the first start delay happens
	if (previousAcceleration <= 0 && acceleration > 0 && linear_velocity.length() < 5):
		# if the timer has ended throttle it
		if accelerationTimer > accelerationDelaySeconds:
			accelerationTimer = 0
		else:
			accelerationTimer += delta
			acceleration = 0
	
	previousAcceleration = acceleration

	# brake as quickly as possible if moving and backward is pressed
	# prevent moving backward
	if acceleration < 0 and linear_velocity.length() > 0:
		brake = mass / 2
		acceleration = 0

	if acceleration > 0:
		brake = 0

	# simulated regenerative braking
	if acceleration == 0:
		brake = mass / 8

	# # get the rpm of all the wheels and create an average
	var rpm = abs(($BL.get_rpm() + $BR.get_rpm() + $FL.get_rpm() + $FR.get_rpm()) / 4)

	if forward:
		engine_force = acceleration * max_torque * (1 - rpm / max_rpm)

	if !forward and engine_force <= 0:
		engine_force = -acceleration * max_torque * (1 - rpm / max_rpm_reverse)
