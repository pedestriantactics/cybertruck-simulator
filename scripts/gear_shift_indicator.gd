extends Label

# this indicates if the driver is in D or R mode
@export var vehicle_node: NodePath
@onready var audio_stream_player = get_child(0)
@export var forward_sound: AudioStream
@export var reverse_sound: AudioStream
var vehicle
var previous_forward = false

func _ready():
    if vehicle_node != null:
        # get the vehicle script
        vehicle = get_node(vehicle_node)
    else:
        printerr("vehicle node not set")

func _process(delta):
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
