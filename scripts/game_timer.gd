extends Label

# this script runs a timer which is displayed and updated in the game
# once the timer runs out, it changes to the desired scene

@onready var scene_changer = get_node("/root/SceneChanger")
@onready var timer_animation = $"./AnimationPlayer"

var started = false

var timer = 0.00
@export var timer_start_seconds = 180
var seconds = 0

func _ready():
	timer = timer_start_seconds
	seconds = int(timer)

func _process(delta):
	if !started&&(!InputProcessor.can_process_game_input||Input.get_axis("move_backward", "move_forward") == 0):
		return ;
		
	started = true
	timer -= delta

	# check if we've hit the next second in our timer
	var next_seconds = int(timer)
	if next_seconds != seconds:
		seconds = next_seconds
		
		# update the label for the timer
		var fmt_minutes = int(timer / 60.0)
		var fmt_seconds = int(timer) % 60
		text = str(fmt_minutes) + ":" + str(fmt_seconds).pad_zeros(2)

		# if we're at zero seconds, change the scene
		if seconds == 0:
			scene_changer.change_scene("end")
			set_process(false)
			return
		elif seconds <= 10:
			timer_animation.play("timer_warn")
