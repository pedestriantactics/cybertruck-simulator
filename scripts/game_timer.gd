extends Label

# this script runs a timer which is displayed and updated in the game
# once the timer runs out, it changes to the desired scene

@onready var scene_changer = get_node("/root/SceneChanger")

var started = false

var timer = 0.00
var timer_start_seconds = 60*2

func _ready():
	timer = timer_start_seconds

func _process(delta):
	if !started && (!InputProcessor.can_process_game_input || Input.get_axis("move_backward", "move_forward") == 0):
		return;
		
	started = true
	timer -= delta
	# convert the float of seconds into minutes and seconds
	var minutes = int(timer / 60.0)
	var seconds = int(timer) % 60
	var str_seconds = str(seconds)
	if seconds < 10:
		str_seconds = "0" + str_seconds
	text = str(minutes) + ":" + str_seconds
	if timer <= 0:
		scene_changer.change_scene("menu")
