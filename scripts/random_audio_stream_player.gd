extends AudioStreamPlayer

@export var mute = false
@export var sounds: Array[AudioStream] = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func play_random():
	if mute:
		return
	if (sounds.size() > 0):
		var sound = sounds[randi() % sounds.size()]
		stream = sound
		play()
	else:
		printerr("no sounds to play")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
