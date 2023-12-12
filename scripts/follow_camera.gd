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

	# Assuming vehicle is a reference to your VehicleBody3D instance
	get_parent().get_parent().collision_occurred.connect(_on_vehicle_collision_occurred)
	get_parent().get_parent().shake_occurred.connect(_on_vehicle_collision_occurred)

func _on_vehicle_collision_occurred(impact):
	shakeStrength += impact
	# adjust this line based on how you want the impact to affect the shakeStrength


func _physics_process(_delta):
	var target = get_parent().get_global_transform().origin
	var pos = get_global_transform().origin

	var from_target = pos - target

	# Check ranges.
	if from_target.length() < min_distance:
		from_target = from_target.normalized() * min_distance
	elif from_target.length() > max_distance:
		from_target = from_target.normalized() * max_distance

	from_target.y = height

	pos = target + from_target

	look_at_from_position(pos, target, Vector3.UP)

	# Turn a little up or down
	var t = get_transform()
	t.basis = Basis(t.basis[0], deg_to_rad(angle_v_adjust)) * t.basis
	set_transform(t)

	# reduce the shake strength so it goes back to 0 over shakeReturnSeconds
	shakeStrength = lerp(shakeStrength, 0.0, _delta / shakeReturnSeconds)

	# shake
	if shakeTimer > 0:
		shakeTimer -= _delta
		return;
	
	shakeTimer = shakeDelay
	# create a shake effect that wiggles randomly on the x and y axis times the shake strength
	var shake = Vector3(randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength), randf_range(-shakeStrength, shakeStrength)/2)
	# add the shake to the camera's position
	get_parent().position = shake
