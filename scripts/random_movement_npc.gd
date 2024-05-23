extends RigidBody3D

# this creates random movement by setting a timer
# there is a function to set a random movement direction along x and z and start the timer for a random period within a spectrum
# when the timer runs out the random movement and timer function is started again
# the update cycle will perform the movement

var next_direction = Vector3.ZERO
var timer = 0.0
@export var change_movement_timer_max = 2.0
@export var change_movement_timer_min = 0.1

func _ready():
	set_random_movement()

func set_random_movement():
	next_direction = Vector3(randf_range( - 1.0, 1.0), 0.0, randf_range( - 1.0, 1.0)).normalized()
	timer = randf_range(change_movement_timer_min, change_movement_timer_max)
	set_process(true)
	
func _physics_process(delta):
	timer -= delta
	if timer <= 0.0:
		set_random_movement()
	# translate the rigid body but only if the body is upright, and hasn't fallen over
	# check this by checking the y value of the global transform
	if global_transform.basis.y.normalized().dot(Vector3(0.0, 1.0, 0.0)) > 0.9:

		# get the current direction of the rigidbody and lerp between it and the new direction
		# this will make the movement smoother
		# var current_direction = global_transform.basis.z.normalized()
		# next_direction = current_direction.lerp(next_direction, .05)

		# global_translate(next_direction * randf_range(0.01, 0.2))
		# reset the forces on the rigid body
		linear_velocity = Vector3.ZERO
		# apply force to the rigidbody but make sure the force doesn't exceed a certain value
		# this will make the movement more realistic
		apply_force(next_direction * randf_range(0.05, 0.5), Vector3.ZERO)
