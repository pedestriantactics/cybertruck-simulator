extends AudioStreamPlayer

# the tire screech is playing on loop by default
# this will turn the volume up if there's a lot of lateral movement

@export var mute = false
@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_volume_db(-80)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
	if velocity.length() < 4 or !parent.is_moving_forward():
		# set the volume to 0
		set_volume_db(-80)
		return

	# set the volume of the tire screech based on the skid of the wheels
	# get the wheels by getting nodes FL, FR, BL, BR which are siblings
	var wheels = []
	for child in parent.get_children():
		if child.name == "FL" or child.name == "FR" or child.name == "BL" or child.name == "BR":
			wheels.append(child)
	var skid = 4
	for wheel in wheels:
		skid -= wheel.get_skidinfo()
		# if the wheel is moving laterally, add to the skid
	# divide the skid by the number of wheels
	skid /= 4

	var calculated_volume = -80 + (skid * 180)
	if calculated_volume > 0:
		calculated_volume = 0

	# set the volume based on the skid
	set_volume_db(calculated_volume)
