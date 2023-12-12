extends AudioStreamPlayer

# this listens to the collision_occurred signal and plays a random sound from an array at the volume of the impact

@export var impact_sounds: Array[AudioStream] = []

@onready var audiostreamplayers = get_children()

# this will be used for sidechain compression
@onready var bus_index = AudioServer.get_bus_index("Ambient")
var bus_default_volume = 0
var bus_return_speed = 300

# Called when the node enters the scene tree for the first time.
func _ready():
	bus_default_volume = AudioServer.get_bus_volume_db(bus_index)
	get_parent().collision_occurred.connect(_on_vehicle_collision_occurred)

func _on_vehicle_collision_occurred(impact):
	if (impact < .5):
		return
	# scale the volume to be -80 for an impact of 0 and 0 for an impact of 2
	var calculated_volume = impact * 20 - 20
	print("impact: " + str(impact) + " volume: " + str(calculated_volume))
	# if the volume is over 0 cap it at 0
	if (calculated_volume > 0):
		calculated_volume = 0
	# set the volume
	# volume_db = calculated_volume
	play_random(calculated_volume)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# if the bus volume is below the default volume, slowly raise it up back to the default depending on the return speed
	var bus_volume = AudioServer.get_bus_volume_db(bus_index)
	if (bus_volume < bus_default_volume):
		AudioServer.set_bus_volume_db(bus_index, bus_volume + bus_return_speed * delta)
	if (bus_volume > bus_default_volume):
		AudioServer.set_bus_volume_db(bus_index, bus_default_volume)

func play_random(volume):
	# play a random audiostream player
	var player = audiostreamplayers[randi() % audiostreamplayers.size()]
	player.volume_db = volume
	player.play()

	# sidechain the bus down
	var bus_volume = AudioServer.get_bus_volume_db(bus_index)
	AudioServer.set_bus_volume_db(bus_index, bus_volume - 10)

	# if (sounds.size() > 0):
	# 	var sound = sounds[randi() % sounds.size()]
	# 	stream = sound
	# 	play()
	# else:
	# 	print("no sounds to play")