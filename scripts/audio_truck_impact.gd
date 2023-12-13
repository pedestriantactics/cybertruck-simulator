extends Node

# this listens to the collision_occurred signal and plays a random sound from an array at the volume of the impact

@export var impact_sounds: Array[AudioStream] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().object_collision_occurred.connect(_on_object_collision_occurred)
	get_parent().static_collision_occurred.connect(_on_object_collision_occurred)

func _on_object_collision_occurred(impact):
	if (impact < .5):
		return
	# scale the volume to be -80 for an impact of 0 and 0 for an impact of 2
	var calculated_volume = impact * 20 - 20
	# if the volume is over 0 cap it at 0
	if (calculated_volume > 0):
		calculated_volume = 0
	play_random_instantiated(impact_sounds, calculated_volume)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# get the children and remove any players that aren't playing
	var audiostreamplayers = get_children()
	for player in audiostreamplayers:
		if (!player.playing):
			player.queue_free()

	# create a function called play that takes in the array of sounds and plays one of them at random
func play_random_instantiated(sounds, volume):
	if (sounds.size() > 0):
		var sound = sounds[randi() % sounds.size()]
		#instantiate a new child audiostreamplayer
		var player = AudioStreamPlayer.new()
		player.bus = "Impacts"
		add_child(player)
		player.stream = sound
		player.volume_db = volume
		player.play()
	else:
		printerr("no sounds to play")