extends AudioStreamPlayer

# the truck audio is autoplaying by default
# the volume is turned down by default
# this script turns the volume up based on the velocity of the parent object (which is the car body)
# this only happens when the acceleration key is down
# the volume is capped at 0db

@onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	set_volume_db(-80)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.get_axis("move_backward", "move_forward") <= 0:
		set_volume_db(-80)
		return
	if parent == null:
		return
	# get the velocity of the parent object
	var velocity = parent.get_linear_velocity()
	# get the length of the velocity vector
	var speed = velocity.length()
	# scale the speed so that 0 is -80 and 100 is 0
	speed = lerp(-80, 0, speed / 10)
	# set the volume to the length of the velocity vector
	set_volume_db(speed)
	# cap the volume at 0db
	if get_volume_db() > 0:
		set_volume_db(0)
