extends AudioStreamPlayer3D

# this gets collision information from the rigidbody3d parent and plays a random sound from an array 
# the sound is played at a volume equivelant to the velocity change of the rigidbody3d parent

@export var mute = false
@onready var rigid_body = get_parent()
@export var sounds: Array[AudioStream]

var last_velocity_length = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	# rigid_body.body_entered.connect(_on_body_entered)
	# rigid_body.contact_monitor = true
	# pass # Replace with function body.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var velocity_length = rigid_body.linear_velocity.length()
	var velocity_change = velocity_length - last_velocity_length
	if (velocity_change > 0.8):
		play_random(sounds, 0)
	
	last_velocity_length = rigid_body.linear_velocity.length()
	# pass

# func _on_body_entered(body):
# 	# compare the velocities to see if it's worth counting as an impact
# 	var velocity_length = rigid_body.linear_velocity.length()
# 	var velocity_change = last_velocity_length - velocity_length
# 	if (velocity_change > 0.1):
# 		play_random(sounds, 0)

func play_random(in_sounds, volume):
	if mute:
		return
	if (sounds.size() > 0):
		stop()
		var sound = sounds[randi() % sounds.size()]
		stream = sound
		volume_db = volume
		play()
	else:
		printerr("no sounds to play")
