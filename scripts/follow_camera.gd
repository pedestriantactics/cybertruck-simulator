extends Camera3D


@export var min_distance = 2.0
@export var max_distance = 4.0
@export var angle_v_adjust = 0.0

@export var height = 1.5
var collision_exception = []

var shakeStrength = 0.0
var shakeReturnSeconds = 0.05
@export var shakeDelay = .01

var shakeTimer = 0

# var relative_start_position: Vector3
# var relative_start_rotation: Vector3


func _ready():
	# Find collision exceptions for ray.
	var node = self
	while(node):
		if (node is RigidBody3D):
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()

	# This detaches the camera transform from the parent spatial node.
	set_as_top_level(true)

	# Save the relative start position but it needs to be relative to the target's rotation too
	# relative_start_position = position - get_parent().position
	# relative_start_rotation = rotation - get_parent().rotation

	# Assuming vehicle is a reference to your VehicleBody3D instance
	get_parent().get_parent().object_collision_occurred.connect(_on_object_collision_occurred)
	get_parent().get_parent().static_collision_occurred.connect(_on_vehicle_collision_occurred)
	get_parent().get_parent().shake_occurred.connect(_on_vehicle_collision_occurred)

func _on_object_collision_occurred(impact, collision_info):
	_on_vehicle_collision_occurred(impact)

func _on_vehicle_collision_occurred(impact):
	shakeStrength += impact/2.1
	# adjust this line based on how you want the impact to affect the shakeStrength



func _physics_process(_delta):

	var target = get_parent().get_global_transform().origin
	var target_rot = get_parent().get_global_transform().basis
	var pos = get_global_transform().origin

	var from_target = pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	from_target.y = height

	pos = target + from_target

	# code to rotate to the back of the vehicle goes here

	look_at_from_position(pos, target, Vector3.UP)

	# adjust angle
	var angle = get_rotation_degrees()
	angle.x += angle_v_adjust
	set_rotation_degrees(angle)

	# reduce the shake strength so it goes back to 0 over shakeReturnSeconds
	shakeStrength = lerp(shakeStrength, 0.0, _delta / shakeReturnSeconds)

	# shake
	if shakeTimer > 0:
		shakeTimer -= _delta
		return;
	
	shakeTimer = shakeDelay
	# create a shake effect that wiggles randomly on the x and y axis times the shake strength
	var shake = Vector3(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength)/2)
	# cap shake to a certain value
	var max_shake = 0.18
	shake = Vector3(clamp(shake.x, -max_shake, max_shake), clamp(shake.y, -max_shake, max_shake), clamp(shake.z, -max_shake, max_shake))
	# add the shake to the camera's position

	var new_position = shake

	get_parent().position = new_position
