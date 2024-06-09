extends AudioStreamPlayer

# the tire screech is playing on loop by default
# this will turn the volume up if there's a lot of lateral movement

@export var mute = false
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_volume_db(-80)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# if below a volume stop playing at all
	if (playing and parent.get_linear_velocity().length() < 1) or mute:
		stop()
	if !playing and parent.get_linear_velocity().length() > 1:
		play()

	if mute:
		return
	
	if parent == null:
		return

	# get the velocity of the parent object
	var velocity = parent.get_linear_velocity()

	# if the velocity is below a certain threshold or the parent is not moving forward
	# if velocity.length() < 4 or !parent.is_moving_forward():
	# 	# set the volume to 0
	# 	set_volume_db(-80)
	# 	return

	# set the volume of the tire screech based on the skid of the wheels
	# get the wheels by getting nodes FL, FR, BL, BR which are siblings
	var wheels = []
	for child in parent.get_children():
		if child.name == "BL" or child.name == "BR":
			wheels.append(child)
	# 0 is lost control, 1 is grip
	var skid_sum = 0
	for wheel in wheels:
		skid_sum += wheel.get_skidinfo()
		# we should end up with a number between 0 and 1
		# 0 means skidding and 1 means not skidding
	skid_sum /= wheels.size()
	# invert the number so it's between 1 and 0, 0 being no skid and 1 being skid
	skid_sum = 1 - skid_sum
	var calculated_volume = -80.00
	var lerp_speed = 0.5
	var current_volume = get_volume_db()
	if skid_sum > 0.5:
		# lerp the current volume to 0
		calculated_volume = lerp(current_volume, 0.0, lerp_speed)
	else:
		# lerp the current volume to -80
		calculated_volume = lerp(current_volume, -80.0, lerp_speed)

	set_volume_db(calculated_volume)
