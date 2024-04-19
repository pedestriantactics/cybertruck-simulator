extends Label

# this indicates if the driver is in D or R mode
@export var vehicle_node: NodePath
@onready var audio_stream_player = get_child(0)
@export var forward_sound: AudioStream
@export var reverse_sound: AudioStream
# get the nodepath for the tutorial overlay
@export var tutorial_overlay_path: NodePath
@onready var tutorial_overlay = get_node(tutorial_overlay_path)

var vehicle
var previous_forward = false
var previous_parked = true

func _ready():
	tutorial_overlay.show()
	if vehicle_node != null:
		# get the vehicle script
		vehicle = get_node(vehicle_node)
	else:
		printerr("vehicle node not set")

func _process(delta):
	if vehicle.parked:
		text = "P"
		return
	if previous_parked:
		tutorial_overlay.hide()
		audio_stream_player.stream = forward_sound
		text = "D"
		audio_stream_player.play()
		previous_parked = false
		return
	if vehicle.forward == previous_forward:
		return
	previous_forward = vehicle.forward
	if vehicle.forward:
		text = "D"
		audio_stream_player.stream = forward_sound
		audio_stream_player.play()
	else:
		text = "R"
		audio_stream_player.stream = reverse_sound
		audio_stream_player.play()
