extends Label

# this script runs a timer which is displayed and updated in the game
# once the timer runs out, it changes to the desired scene

@onready var scene_changer = get_node("/root/SceneChanger")
@onready var timer_animation = $"./AnimationPlayer"

var started = false
var blocked = false

var timer = 0.00
@export var timer_start_seconds = 90
var seconds = 0

func _ready():
	text = ""
	timer = timer_start_seconds
	seconds = int(timer)
	DevConsole.command.connect(handle_command)
	DevConsole.help_text["timer"] = "timer <number> - set the timer to the given number of seconds, or no number to check the current value"
	DevConsole.help_text["stoptimer"] = "stop the timer"
	DevConsole.help_text["starttimer"] = "start the timer"

func handle_command(text_command):
	var check_command = ""

	check_command = "timer"
	if text_command.begins_with(check_command):
		var checked_number = text_command.replace(check_command, "").strip_edges()
		if checked_number.is_valid_float():
			timer = float(checked_number)
		DevConsole.debug_print("timer set to: " + str(checked_number))

	match text_command:
		"stoptimer":
			started = false
			blocked = true
			DevConsole.debug_print("timer stopped")

		"starttimer":
			started = false
			blocked = false
			DevConsole.debug_print("timer started")

		"timer":
			DevConsole.debug_print("timer: " + str(timer))

func _process(delta):
	if blocked:
		return;
	if !started&&(!InputProcessor.can_process_game_input||!Input.is_action_just_pressed("toggle_reverse")):
		return;
		
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
