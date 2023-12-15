extends AudioStreamPlayer

# this will contain three audio streams to play
# one for the acceleration which will be an array of three sounds, played randonmly
# one for the deceleration sound
# one for the braking sound
# this also checks the velocity of the parent to choose whether to play the hard acceleration or soft

@export var mute = false
@export var acceleration_sounds: Array[AudioStream] = []
@export var soft_acceleration_sounds: Array[AudioStream] = []
@export var deceleration_sounds: Array[AudioStream] = []
@export var braking_sounds: Array[AudioStream] = []

# var lastInputAxis = 0

# @onready var parent = get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# # Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	Input.get_axis("move_backward", "move_forward")
# 	if (lastInputAxis != Input.get_axis("move_backward", "move_forward")):
# 		lastInputAxis = Input.get_axis("move_backward", "move_forward")
# 		# accelerate
# 		if lastInputAxis > 0 and parent.forward && parent.get_linear_velocity().length() > 5:
# 			play_random(acceleration_sounds)
# 		# if you let go while moving
# 		if lastInputAxis == 0 and parent.get_linear_velocity().length() > 5:
# 			play_random(deceleration_sounds)
# 			return
		
# 		# if (lastInputAxis > 0):
# 		# 	if (parent.get_linear_velocity().length() > 5 or !parent.forward):
# 		# 		play_random(soft_acceleration_sounds)
# 		# 	else:
# 		# 		play_random(acceleration_sounds)
# 		# elif (lastInputAxis < 0):
# 		# 	play_random(deceleration_sounds)
# 		# else:
# 		# 	play_random(braking_sounds)
			
# create a function called play that takes in the array of sounds and plays one of them at random
func play_random(sounds):
	if mute:
		return
	if (sounds.size() > 0):
		stop()
		var sound = sounds[randi() % sounds.size()]
		stream = sound
		play()
	else:
		printerr("no sounds to play")
