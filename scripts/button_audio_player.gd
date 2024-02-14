extends AudioStreamPlayer

@export var mute = false
@export var select_sounds: Array[AudioStream] = []
@export var press_sound: AudioStream


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	# the button is the parent, connect it
	var button = get_parent() as Button
	# connect the on focus or highlight to playing the press sound
	button.focus_entered.connect(_selected)
	button.pressed.connect(_pressed)


func _pressed():
	if mute:
		return
	if press_sound != null:
		stream = press_sound
		play()
	else:
		print("No press sound assigned to the button")
	

func _selected():
	if mute:
		return
	if select_sounds.size() > 0:
		stream = select_sounds[randi() % select_sounds.size()]
		play()
	else:
		print("No select sound assigned to the button")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
