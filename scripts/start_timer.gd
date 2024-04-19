extends Control

# this script turns off all input in the game, runs a timer that is specified in seconds, and then turns on input
# the script also makes itself visible and displays the timer
# the label inside the control changes each second that the timer updates

@onready var timer_label = get_node("TimerLabel")

var timer = 0
var timer_max = 0
var timer_running = false

func _ready():
	InputProcessor.can_process_game_input = false
	timer = timer_max
	timer_running = true
	set_visible(true)

func _process(delta):
	if timer_running:
		timer -= delta
		timer_label.text = str(int(timer))
		if timer <= 0:
			timer_running = false
			set_process(false)
			set_visible(false)
			timer_label.text = ""
			InputProcessor.can_process_game_input = true
