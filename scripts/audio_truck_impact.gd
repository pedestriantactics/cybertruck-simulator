extends Node

# this listens to the collision_occurred signal and plays a random sound from an array at the volume of the impact

@export var mute = false
@export var impact_sounds: Array[AudioStream] = []
@export var impact_hard_sounds: Array[AudioStream] = []
@export var crash_sounds: Array[AudioStream] = []

var hold_frames = 5
var pause_timer = 0
# var pause_recovery_frames = 10
# var pause_recovery_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_parent().object_collision_occurred.connect(_on_object_collision_occurred)
	get_parent().static_collision_occurred.connect(_on_static_collision_occurred)

func _on_object_collision_occurred(impact, collision_info):
	if (impact < .2):
		return
	
	var final_sounds = impact_sounds
	if (impact > .75):
		final_sounds = impact_hard_sounds
	# scale the volume to be -80 for an impact of 0 and 0 for an impact of .KEY_5
	var calculated_volume = impact * 100 - 30
	print(calculated_volume)
	# temp
	# calculated_volume = 0
	# if the volume is over 0 cap it at 0
	if (calculated_volume > 0):
		calculated_volume = 0
	play_random_instantiated(final_sounds, calculated_volume)

	# if (impact > .3):
	# 	pause_timer = hold_frames

func _on_static_collision_occurred(impact):
	if (impact < .1):
		return
	
	var final_sounds = impact_hard_sounds
	if (impact > 1):
		final_sounds = crash_sounds
	# scale the volume to be -80 for an impact of 0 and 0 for an impact of 2
	var calculated_volume = impact * 40 - 20
	# if the volume is over 0 cap it at 0
	if (calculated_volume > 0):
		calculated_volume = 0
	play_random_instantiated(final_sounds, calculated_volume)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# get the children and remove any players that aren't playing
	var audiostreamplayers = get_children()
	for player in audiostreamplayers:
		if (!player.playing):
			player.queue_free()
	# if (pause_timer > 0):
	# 	# pause_recovery_timer = pause_recovery_frames
	# 	pause_timer -= 1
	# 	get_tree().set_pause(true)
	# else:
	# 	get_tree().set_pause(false)
	# 	# pause_recovery_timer -= 1


	# create a function called play that takes in the array of sounds and plays one of them at random
func play_random_instantiated(sounds, volume):
	if mute:
		return
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
