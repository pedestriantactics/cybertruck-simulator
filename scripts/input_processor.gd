extends Node
# this handles a global variable that determines whether scripts should process input or not

var can_process_game_input = true;

func _ready():
	DevConsole.command.connect(handle_command)
	DevConsole.help_text["input"] = "Toggles whether the game should process input or not"

func handle_command(text_command):
	match text_command:
		"input":
			# set this camera to be the active camera if it isn't
			can_process_game_input = !can_process_game_input
			DevConsole.debug_print("Input processing: " + str(can_process_game_input))