extends Node

# this will be used for sidechain compression
@onready var bus_index = AudioServer.get_bus_index("Ambient")
var bus_default_volume = 0
var bus_impact_speed = 500
var bus_return_speed = 300

var volume_guide = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	bus_default_volume = AudioServer.get_bus_volume_db(bus_index)
	get_parent().object_collision_occurred.connect(_on_impact)
	get_parent().static_collision_occurred.connect(_on_impact)

func _on_impact(impact):
	# var bus_volume = AudioServer.get_bus_volume_db(bus_index)
	volume_guide = bus_default_volume - 80
	# AudioServer.set_bus_volume_db(bus_index, bus_volume - 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var bus_volume = AudioServer.get_bus_volume_db(bus_index)

	# compress
	if volume_guide < bus_default_volume:
		# make sure it doesn't go too low
		var desired_volume = bus_volume - (delta * bus_impact_speed)
		if desired_volume < volume_guide:
			desired_volume = volume_guide
		AudioServer.set_bus_volume_db(bus_index, desired_volume)

	# decompress	
	if volume_guide == bus_default_volume && bus_volume < bus_default_volume:
		# protect the ears by capping at the default volume
		var desired_volume = bus_volume + (delta * bus_return_speed)
		if desired_volume > bus_default_volume:
			desired_volume = bus_default_volume
		
		AudioServer.set_bus_volume_db(bus_index, desired_volume)
	
	# reset the volume guide	
	volume_guide = bus_default_volume
