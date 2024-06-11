extends AudioStreamPlayer3D

# this will set a random timer and then play the sound

@export var max_time = 2.0
@export var min_time = 0.3

@onready var parent = get_parent()

var timer = 0.0

func _process(delta):
	if parent.visible == false:
		return
	timer -= delta
	if timer <= 0:
		timer = randf() * (max_time - min_time) + min_time
		play()
